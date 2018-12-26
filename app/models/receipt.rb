class Receipt < ApplicationRecord
  #RECIBO DE PAGO
  belongs_to :invoice
  belongs_to :client
  belongs_to :company

  has_one  :account_movement

  has_many :payments, through: :invoice

  after_save :touch_account_movement
  before_save :set_number, on: :create

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

  #PROCESOS
  	def touch_account_movement
  		am 				     = AccountMovement.where(receipt_id: id).first_or_initialize
  		am.client_id 	 = invoice.client_id
  		am.receipt_id  = id
  		am.cbte_tipo	 = invoice.is_credit_note? ? "Devolución" : "Recibo X"
  		am.debe 		   = invoice.is_credit_note?
  		am.haber 		   = invoice.is_invoice?
  		am.total 		   = total.to_f
      if invoice.is_credit_note?
  		  am.saldo       = invoice.client.saldo.to_f - total.to_f unless !am.new_record?
      else
        am.saldo       = invoice.client.saldo.to_f + total.to_f unless !am.new_record?
      end
  		am.save
  	end

    def set_number
      last_r = Receipt.where(company_id: company_id).last
      self.number = last_r.nil? ? "00001" : (last_r.number.to_i + 1).to_s.rjust(5,padstr= '0') unless (!self.number.blank? || self.total < 0)
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

    def letra_tipo
      if cbte_tipo!= "99"
        CBTE_TIPO[cbte_tipo][-1]
      else
        "D"
      end
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
