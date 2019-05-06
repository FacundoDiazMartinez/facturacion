module ArrivalNotesHelper
	def arrival_state_label_helper arrival_note
		pp "#{arrival_note.number} - #{arrival_note.state}"
	    case arrival_note.state
	    when 'Pendiente'
	      	arrival_label_span('badge badge-pill badge-warning', 'Pendiente')
	    when 'Anulado'
	      	arrival_label_span('badge badge-pill badge-secondary', 'Anulado')
	    when 'Finalizado'
	     	arrival_label_span('badge badge-pill badge-success', 'Finalizado')
	    end
	end

  	def arrival_label_span(klass, label)
    	"<span class='#{klass}'>#{label}</span>".html_safe
  	end
end
