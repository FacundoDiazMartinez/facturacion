class Commissioner < ApplicationRecord
  	belongs_to :user, optional: true
  	belongs_to :invoice_detail, optional: true


    before_validation :set_total_commission #se setea en 0 el total de comisión, para después modificarlo cuando se guarda la factura
    validates_presence_of :user_id, message: "Esta intentado guardar comisiones sin personal asignado."
    validates_inclusion_of :percentage, :in => 0..100, message: "El porcentaje de comisión del mecánico no puede superar el 100%"

    default_scope {joins(invoice_detail: :invoice).where("invoices.active = 't'")}


    def set_total_commission
      self.total_commission = invoice_detail.subtotal.to_f * percentage.to_f / 100
    end

  	def invoice
  		invoice_detail.invoice
  	end

  	def full_number
  		invoice.editable? ? "Sin confirmar" : invoice.full_number
  	end

  	def cbte_fch
  		invoice.editable? ? "Sin confirmar" : invoice.cbte_fch
  	end

  	def total
		invoice.total
  	end

  	def tipo
  		invoice.tipo
  	end

  	def self.search_by_date from, to
	  	if !from.blank? && !to.blank?
	  		if from.respond_to?(:to_time) && to.respond_to?(:to_time)
	  			where(created_at: from.to_time.beginning_of_day..to.to_time.end_of_day)
	  		else
	  			all
	  		end
		  else
			 all
		  end
    end

    def self.search_by_cbte_number cbte_number
      if not cbte_number.blank?
        joins(invoice_detail: :invoice).where("invoices.comp_number ILIKE ?", "%#{cbte_number}%")
      else
        all
      end
    end
end
