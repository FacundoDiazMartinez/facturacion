class IvaBook < ApplicationRecord
  belongs_to :invoice, optional: true
  belongs_to :purchase_invoice, optional: true

  default_scope { where(active: true) }

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

    def self.find_by_tipo iva_compra
      if not iva_compra.blank?
        if iva_compra
          where(tipo: "Crédito Fiscal")
        else
          where(tipo: "Débito Fiscal")
        end
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #FUNCIONES
    def is_credit? #es credito cuando tiene un purchase invoice id
      not purchase_invoice_id.nil?
    end

    def is_debit? #es debito cuando tiene un invoice id
      not invoice_id.nil?
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #FUNCIONES

  #ATRIBUTOS
    def clase
      invoice_id.nil? ? "Crédito Fiscal" : "Débito Fiscal"
    end

    def full_invoice
      if is_debit?
        Invoice.unscoped do
          "#{CBTE_TIPO[invoice.cbte_tipo]} - #{invoice.sale_point.name}-#{invoice.comp_number}"
        end
      else
        PurchaseInvoice.unscoped do
          "#{CBTE_TIPO[purchase_invoice.cbte_tipo]} - #{purchase_invoice.number}"
        end
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
