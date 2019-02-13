class Receipt < ApplicationRecord
  #RECIBO DE PAGO
  belongs_to :client
  belongs_to :sale_point
  belongs_to :company

  has_one  :account_movement
  has_many :account_movement_payments, through: :account_movement
  has_many :invoices
  has_many :invoice_details, through: :invoices

  after_save :touch_account_movement
  before_validation :set_number, on: :create
  before_validation :check_total

  validates_uniqueness_of :number, scope: [:company, :active], message: "No se puede repetir el numero de recibo."

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
        destroy unless total > 0.0
      end
    end
    
  #VALIDACIONES

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
        r = invoice.receipt || Receipt.new 
        r.cbte_tipo   = invoice.is_credit_note? ? "99" : "00"
        r.total       = invoice.total_pay
        r.date        = invoice.created_at
        r.company_id  = invoice.company_id
        r.client_id   = invoice.client_id
        r.sale_point_id = invoice.sale_point_id
        r.user_id     = invoice.user_id
        if r.save
          invoice.update_column(:receipt_id, r.id)
        end
      end
    end

    # def set_number
    #   last_receipt = Receipt.where(company_id: company_id).last
    #   self.number ||= last_receipt.nil? ? "00000001" : (last_receipt.number.to_i + 1).to_s.rjust(8,padstr= '0')
    # end
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
      !persisted?
    end
  #ATRIBUTOS

  #FUNCIONES
    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
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
