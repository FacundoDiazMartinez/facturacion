module BudgetsHelper
	def state_label_helper_budget budget
	    case budget.state
	    when 'Vencido'
	      	label_span('badge badge-pill badge-danger', 'Vencido')
	    when 'Generado'
	      	label_span('badge badge-pill badge-secondary', 'Generado')
	    when 'Válido'
	     	label_span('badge badge-pill badge-info', 'Válido')
	    when 'Concretado'
	     	label_span('badge badge-pill badge-success', 'Concretado')
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
