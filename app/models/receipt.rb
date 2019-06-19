class Receipt < ApplicationRecord
  include Deleteable
  #RECIBO DE PAGO
  belongs_to :client
  belongs_to :sale_point
  belongs_to :company

  has_one  :account_movement
  has_many :account_movement_payments, through: :account_movement
  has_many :receipt_details, dependent: :destroy
  has_many :invoices, through: :receipt_details

  accepts_nested_attributes_for :receipt_details, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :account_movement, reject_if: :all_blank, allow_destroy: true

  before_validation :set_number, on: :create
  before_validation :validate_receipt_detail
  before_validation :set_total ## establece el total del recibo a partir de los pagos

  STATES = ["Pendiente", "Finalizado"]

  validates_uniqueness_of :number, scope: [:company, :active], message: "No se puede repetir el número de recibo."
  validates_inclusion_of  :state, in: STATES
  validate                :uniqueness_of_invoice_id
  validate                :at_least_one_active_payment # valida que exista al menos un pago para recibos confirmados

  after_save :save_amount_available

  default_scope {where(active: true)}
  scope :no_devolution, -> {where.not(cbte_tipo: "99")}

  CBTE_TIPO = {
    "04"=>"Recibo A",
    "09"=>"Recibo B",
    "15"=>"Recibo C",
    "54"=>"Recibo M",
    "00"=>"Recibo X",
    "99"=>"Devolución"
  }

  #FILTROS DE BUSQUEDA
    def self.find_by_period from, to
  		if !from.blank? && !to.blank?
  			where(date: from..to)
  		else
  			all
  		end
  	end

    def self.search_by_client name
      if not name.blank?
        joins(:client).where("clients.name ILIKE ?", "%#{name}%")
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #VALIDACIONES
    def uniqueness_of_invoice_id
      invoice_ids = receipt_details.map{ |detail| detail.invoice_id unless detail.marked_for_destruction? }
      errors.add(:base, "Está intentando vincular dos o más veces los mismos comprobantes.") unless invoice_ids.uniq.length == invoice_ids.length
    end

    def payments_length_valid?
      pp "ACAAAAA"
      account_movement.account_movement_payments.where(generated_by_system: false).reject(&:marked_for_destruction?).count > 0
    end

    def at_least_one_active_payment
      if self.state == "Finalizado" && !payments_length_valid?
        errors.add("Pagos", "Debe registrar al menos un pago.")
      end
    end

    ## calcula la suma de los pagos del recibo después de guardar
    def set_total
      self.total  = self.account_movement.account_movement_payments.where(generated_by_system: false).sum(:total)
    end

    ## valida que las facturas asociadas pertenecen al cliente
    def validate_receipt_detail
      receipt_details.each{|rd| rd.invoices_clients_validation}
    end

  #VALIDACIONES

  #ATRIBUTOS
    def account_movement_payments
      super.where.not(type_of_payment: "6")
    end

    def client
      Client.unscoped{ super }
    end

    def client_name
      client.nil? ? "Sin nombre" : client.name
    end

    def nombre_comprobante
      CBTE_TIPO[cbte_tipo]
    end

    def type_of_model
      "receipt"
    end

  #ATRIBUTOS

  #PROCESOS

  	def touch_account_movement
		  AccountMovement.create_from_receipt(self)
      self.account_movement.reload
      AccountMovement.unscoped do
        self.update(total: self.account_movement.total)
      end
    end

    def set_number
      last_r = Receipt.where(company_id: company_id).last
      self.number = last_r.nil? ? "00000001" : (last_r.number.to_i + 1).to_s.rjust(8,padstr= '0') unless (!self.number.blank? || self.total < 0)
    end

    def self.create_from_invoice invoice
      if invoice.state == "Confirmado"
        if invoice.receipts.empty? && invoice.total_pay > 0
          r = Receipt.new
          r.cbte_tipo   = invoice.is_credit_note? ? "99" : "00"
          r.total       = invoice.total_pay
          r.date        = invoice.created_at
          r.company_id  = invoice.company_id
          r.client_id   = invoice.client_id
          r.sale_point_id = invoice.sale_point_id
          r.user_id     = invoice.user_id
          r.state       = "Finalizado"
          if r.save
            ReceiptDetail.save_from_invoice(r, invoice)
            r.touch_account_movement  #con esto crea el movimiento de cta corriente correspondiente al recibo generado por la factura
          else
            pp r.errors
          end
        else
          invoice.receipts.each do |r|
            if invoice.saved_change_to_total_pay?
              r.total      += invoice.saved_change_to_total_pay.last - invoice.saved_change_to_total_pay.first
              r.user_id     = invoice.user_id
            end
            ReceiptDetail.save_from_invoice(r, invoice) unless !r.save
          end
        end
      end
    end

    def destroy
  		update_column(:active, false)
  		run_callbacks :destroy
  	end

    def calculate_invoice_payment_nil
      total = 0
      receipt_details.invoice_payment.where_not(invoice_payment.nil?).each do |detail|
        total += detail.total
      end
      return total.round(2)
    end

  #PROCESOS

  #ATRIBUTOS

    def full_name
      "R#{letra_tipo}: #{number}"
    end

    def full_invoice
      Invoice.unscoped do
        full_invoice = []
        invoices.each do |invoice|
          full_invoice << "#{Afip::CBTE_TIPO[invoice.cbte_tipo]} - #{invoice.sale_point.name}-#{invoice.comp_number}"
        end
        return full_invoice.uniq.join(", ")
      end
    end

    def tipo
      total < 0 ? "Devolución" : "Pago"
    end

    def letra_tipo
      if cbte_tipo!= "99"
        CBTE_TIPO[cbte_tipo][-1]
      else
        "D"
      end
    end

    def invoice_comp_number
      invoices.each {|i| i.comp_number}.join(", ")
    end

    def editable?
      state == "Pendiente"
    end

    def account_movement_attributes=(attributes)
      AccountMovement.unscoped { super }
    end

    def full_number
      number
    end

    #Esto se hace para no perder el valor del amount_available y mantenerlo fijo cada vez q se consulte el acc_mov
    def save_amount_available
      if self.account_movement
        save_amount_available = self.account_movement.amount_available
        update_column(:saved_amount_available, save_amount_available)
      else
        update_column(:saved_amount_available, 0.0)
      end
      #Fin
    end
  #ATRIBUTOS

  #FUNCIONES
    def all_payments_string
      payments = self.account_movement_payments.where(generated_by_system: false)
      if !payments.nil?
        array_pagos = payments.map{|p| {type: p.type_of_payment, name: p.payment_name, total: p.total}}
        pagos_reduced = []

        # agrupamos pagos segun tipo de pago y a continuación se suman los "totales" de cada grupo
        pagos_reduced << array_pagos.group_by{|a| a[:name]}.map{|nom,arr| [nom,arr.map{|f| f[:total].to_f}.sum()]}

        showed_payment = ""
        pagos_reduced.first.each_with_index do |arr,i|
          showed_payment = showed_payment + arr[0] + ": $ " + arr[1].to_s
          if ((i+1) < pagos_reduced.first.count)
            showed_payment = showed_payment + " - "
          end
        end
        return showed_payment
      end
    end
  #FUNCIONES
end
