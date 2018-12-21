class Receipt < ApplicationRecord
  #RECIBO DE PAGO
  belongs_to :invoice, optional: true
  belongs_to :client
  belongs_to :company

  has_one  :account_movement

  has_many :payments, through: :invoice

  after_save :touch_account_movement
  before_save :set_number, on: :create

  default_scope {where(active: true)}

  CBTE_TIPO = {
    "04"=>"Recibo A",
    "09"=>"Recibo B",
    "15"=>"Recibo C",
    "54"=>"Recibo M",
    "00"=>"Recibo X",
    "99"=>"Devolución"
  }

  #PROCESOS
  	def touch_account_movement
  		AccountMovement.create_from_receipt(self)
  	end

    def set_number
      last_r = Receipt.where(company_id: company_id).last
      self.number = last_r.nil? ? "00001" : (last_r.number.to_i + 1).to_s.rjust(5,padstr= '0') unless (!self.number.blank? || self.total < 0)
    end

    def self.create_from_invoice invoice
      r = Receipt.where(invoice_id: invoice.id).first_or_initialize
      r.cbte_tipo   = invoice.is_credit_note? ? "99" : "00"
      r.total       = invoice.total_pay
      r.date        = invoice.created_at
      r.company_id  = invoice.company_id
      r.save
    end
  #PROCESOS

  #ATRIBUTOS
    def full_invoice
      Invoice.unscoped do
        "#{Afip::CBTE_TIPO[invoice.cbte_tipo]} - #{invoice.sale_point.name}-#{invoice.comp_number}"
      end
    end

    def client
      invoice.client
    end

    def tipo
      total < 0 ? "Devolución" : "Pago"
    end
  #ATRIBUTOS

  #FUNCIONES
    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #FUNCIONES
end
