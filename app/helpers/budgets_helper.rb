module BudgetsHelper
	def state_label_helper_budget budget
	    case budget.state
	    when 'Vencido'
	      	label_span('badge badge-pill badge-warning', 'Vencido')
	    when 'Confirmado'
	      	label_span('badge badge-pill badge-info', 'Confirmado')
	    when 'Válido'
	     	label_span('badge badge-pill badge-secondary', 'Válido')
	    when 'Facturado'
	     	label_span('badge badge-pill badge-success', 'Facturado')
	    end
	end

  	def label_span(klass, label)
    	"<span class='#{klass}'>#{label}</span>".html_safe
  	end

  	def stock_label_helper_budget budget
	    case budget.reserv_stock
	    when true
	      	label_span('badge badge-pill badge-success', 'Si')
	    when false
	      	label_span('badge badge-pill badge-danger', 'No')
	    end
	end

	def label_span(klass, label)
    	"<span class='#{klass}'>#{label}</span>".html_safe
  	end
end
