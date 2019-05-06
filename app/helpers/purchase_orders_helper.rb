module PurchaseOrdersHelper
	def po_state_label_helper purchase_order
	    case purchase_order.state
	    when 'Pendiente'
	      	label_span('badge badge-pill badge-warning', 'Pendiente')
	    when 'Aprobado'
	      	label_span('badge badge-pill badge-info', 'Aprobado')
	    when 'Finalizada'
	     	label_span('badge badge-pill badge-success', 'Finalizada')
	    end
	end

  	def label_span(klass, label)
    	"<span class='#{klass}'>#{label}</span>".html_safe
  	end

end
