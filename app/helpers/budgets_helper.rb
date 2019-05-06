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
end
