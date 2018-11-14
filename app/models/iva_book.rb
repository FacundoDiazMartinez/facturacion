class IvaBook < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :purchase_invoice, optional: true

  CBTE_TIPO = {
    "01"=>"FA",
    "02"=>"NDA",
    "03"=>"NCA",
    "06"=>"FB",
    "07"=>"NDB",
    "08"=>"NCB",
    "11"=>"FC",
    "12"=>"NDC",
    "13"=>"NCC"
  }


  #FILTROS DE BUSQUEDA
  	def self.find_by_period from, to
  		if from && to
  			where(date: from...to)
  		else
  			all 
  		end
  	end
  #FILTROS DE BUSQUEDA

  #FUNCIONES
    def is_credit?
      not invoice_id.nil?
    end

    def is_debit?
      invoice_id.nil?
    end
  #FUNCIONES

  #ATRIBUTOS
    def clase
      invoice_id.nil? ? "Crédito Fiscal" : "Débito Fiscal"
    end

    def full_invoice
      if is_credit?
        "#{CBTE_TIPO[invoice.cbte_tipo]} - #{invoice.sale_point.name}-#{invoice.comp_number}"
      else
        "#{CBTE_TIPO[purchase_invoice.cbte_tipo]} - #{purchase_invoice.number}"
      end
    end
  #ATRIBUTOS

  #PROCESOS
    def self.add_from_invoice invoice
      ib            = where(invoice_id: invoice.id).first_or_initialize
      ib.tipo       = ib.clase
      ib.company_id = invoice.company_id
      ib.date       = invoice.cbte_fch
      ib.net_amount = invoice.net_amount_sum
      ib.iva_amount = invoice.iva_amount_sum
      ib.total      = ib.net_amount + ib.iva_amount
      ib.save
    end

    def self.add_from_purchase invoice
      ib            = where(purchase_invoice_id: invoice.id).first_or_initialize
      ib.tipo       = ib.clase
      ib.company_id = invoice.company_id
      ib.date       = invoice.date
      ib.net_amount = invoice.net_amount
      ib.iva_amount = invoice.iva_amount
      ib.total      = ib.net_amount + ib.iva_amount
      ib.save
    end
  #PROCESOS  
end
