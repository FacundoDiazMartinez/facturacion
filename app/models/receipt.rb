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

  before_validation :set_number, on: :create #establece un número consecutivo al último recibo perteneciente a la empresa
  before_validation :validate_receipt_detail #valida que los detalles del recibo pertenezcan a la empresa

  STATES = ["Pendiente", "Finalizado"]

  validates_uniqueness_of :number, scope: [:company, :active], message: "Número de recibo repetido."
  validates_inclusion_of  :state, in: STATES
  validate                :uniqueness_of_invoice_id #valida los detalles para que no se repitan los comprobantes a pagar
  validate                :at_least_one_active_payment #valida que exista al menos un pago para recibos CONFIRMADOS

  #after_save :save_amount_available
  after_save :update_daily_cash

  after_touch :account_movement_updated ## establece el total del recibo a partir de los pagos

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

  #VALIDACIONES
    def uniqueness_of_invoice_id
      invoice_ids = receipt_details.map{ |detail| detail.invoice_id unless detail.marked_for_destruction? }
      errors.add(:base, "Está intentando vincular dos o más veces los mismos comprobantes.") unless invoice_ids.uniq.length == invoice_ids.length
    end

    ## al menos un pago para recibos confirmados
    def at_least_one_active_payment
      if self.confirmado?
        errors.add("Pagos", "Debe registrar al menos un pago.") unless self.payments_length_valid?
      end
    end

    ##MAL PORQUE ESTO VALIDARÍA SOLAMENTE QUE TENGA PAGOS POR CUENTA CORRIENTE
    def payments_length_valid?
      account_movement.account_movement_payments.where(generated_by_system: false).reject(&:marked_for_destruction?).count > 0
    end

    ## calcula la suma de los pagos del recibo después de guardar
    ## el touch lo provoca account movement
    def account_movement_updated
      #self.saved_amount_available = self.account_movement.amount_available
      self.total                  = self.account_movement.total
      self.save
    end

    ## valida que las facturas asociadas pertenecen al cliente
    def validate_receipt_detail
      receipt_details.each{ |rd| rd.invoices_clients_validation }
    end
  #VALIDACIONES

  #ATRIBUTOS
    def confirmado?
      self.state == "Finalizado"
    end

    def editable?
      state == "Pendiente"
    end

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
    def set_number
      last_r = Receipt.where(company_id: company_id).last
      self.number = last_r.nil? ? "00000001" : (last_r.number.to_i + 1).to_s.rjust(8,padstr= '0') unless (!self.number.blank? || self.total < 0)
    end

    ## genera un recibo de pago cuando una factura confirmada tiene pagos
    ## ejecutado en after_save de invoice
    def self.create_from_invoice invoice
      if invoice.confirmado? && invoice.total_pay > 0
        if invoice.receipts.empty?
          ##genera un recibo nuevo asociado a la factura (a traves de receipt_details)
          r               = Receipt.new
          r.cbte_tipo     = invoice.is_credit_note? ? "99" : "00"
          r.total         = invoice.total_pay
          r.date          = invoice.created_at
          r.company_id    = invoice.company_id
          r.client_id     = invoice.client_id
          r.sale_point_id = invoice.sale_point_id
          r.user_id       = invoice.user_id
          if r.save
            ReceiptDetail.save_from_invoice(r, invoice) ##genera un detalle para el recibo con vinculación a la factura
            AccountMovement.generate_from_receipt_from_invoice(r, invoice) ##genera un movimiento de cuenta con todos los pagos de la factura
            r.reload ##recarga asociaciones
            r.confirmar!
            r.reload
          else
            pp r.errors
          end
        end
      end
    end

    def destroy
      #unless confirmado?
        update_column(:active, false)
        run_callbacks :destroy
      #end
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

    def account_movement_attributes=(attributes)
      AccountMovement.unscoped { super }
    end

    def full_number
      number
    end

    ## confirma el recibo
    ## al confirmar el recibo se supone que ya están registrados los detalles (comprobantes asociados) del mismo
    ## al confirmar el pago hay que activar el movimiento de cuenta generado, los movimientos de cuenta generados (y activos) deben estar en la cuenta corriente del cliente
    def confirmar!
      unless self.confirmado?
        AccountMovement.unscoped do
          self.account_movement.confirmar!
        end
        self.saved_amount_available = self.account_movement.amount_available ## el saldo para futuras compras se calcula con el movimiento de cuenta confirmado
        self.state                  = "Finalizado"
        self.save!
      end
    end

    def update_daily_cash
      DailyCashMovement.generate_from_receipt self if self.confirmado?
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

  private
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
end
