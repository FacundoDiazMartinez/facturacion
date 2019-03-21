class Receipt < ApplicationRecord
  #RECIBO DE PAGO
  belongs_to :client
  belongs_to :sale_point
  belongs_to :company

  has_one  :account_movement, dependent: :destroy
  has_many :account_movement_payments, through: :account_movement
  has_many :receipt_details
  has_many :invoices, through: :receipt_details
  # has_many :invoice_details, through: :invoices


  before_validation :validate_receipt_detail
  before_validation :set_number, on: :create
  before_validation :check_total
  # after_update :touch_account_movement if Proc.new{ |r| r.state == "Finalizado" }   Ahora se ejecuta desde el controlador (update)

  validates_uniqueness_of :number, scope: [:company, :active], message: "No se puede repetir el numero de recibo."

  default_scope {where(active: true)}
  scope :no_devolution, -> {where.not(cbte_tipo: "99")}

  accepts_nested_attributes_for :receipt_details, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :account_movement, reject_if: :all_blank, allow_destroy: true


  CBTE_TIPO = {
    "04"=>"Recibo A",
    "09"=>"Recibo B",
    "15"=>"Recibo C",
    "54"=>"Recibo M",
    "00"=>"Recibo X",
    "99"=>"Devolución"
  }

  STATES = ["Pendiente", "Finalizado"]


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
        joins(invoice: :client).where("clients.name ILIKE ?", "%#{name}%")
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #VALIDACIONES
    def check_total
      if new_record?
        errors.add(:total, "No se puede crear un recibo por un monto nulo.") unless total > 0.0
      else
        destroy unless total >= 0.0
      end
    end

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

  #ATRIBUTOS

  #PROCESOS

  	def touch_account_movement
		  AccountMovement.create_from_receipt(self)
    end

    def set_number
      last_r = Receipt.where(company_id: company_id).last
      self.number = last_r.nil? ? "00000001" : (last_r.number.to_i + 1).to_s.rjust(8,padstr= '0') unless (!self.number.blank? || self.total < 0)
    end

    def self.create_from_invoice invoice
      if invoice.state == "Confirmado"
        if invoice.receipts.empty?
          r = Receipt.new
          r.cbte_tipo   = invoice.is_credit_note? ? "99" : "00"
          r.total       = invoice.total_pay
          r.date        = invoice.created_at
          r.company_id  = invoice.company_id
          r.client_id   = invoice.client_id
          r.sale_point_id = invoice.sale_point_id
          r.user_id     = invoice.user_id
          r.state       = "Finalizado"
          ReceiptDetail.save_from_invoice(r, invoice) unless !r.save
        else
          invoice.receipts.each do |r|
            r.total      += invoice.saved_change_to_total_pay.last - invoice.saved_change_to_total_pay.first
            r.user_id     = invoice.user_id
            ReceiptDetail.save_from_invoice(r, invoice) unless !r.save
          end
        end
      end
    end

    def set_total
      self.total = total_without_invoices
    end


  #PROCESOS

  #ATRIBUTOS
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
  #ATRIBUTOS

  #FUNCIONES
    def destroy (hard = nil)
      if hard
        super
      else
        update_column(:active, false)
        run_callbacks :destroy
        freeze
      end
    end

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
