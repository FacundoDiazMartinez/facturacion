module DeliveryNotesHelper
	def dn_state_label_helper delivery_note
    case delivery_note.state
    when 'Pendiente'
      	label_span('badge badge-pill badge-warning', 'Pendiente')
  	when 'Anulado'
   		label_span('badge badge-pill badge-danger', 'Anulado')
    when 'Finalizado'
     	label_span('badge badge-pill badge-success', 'Confirmado')
    end
	end

	def label_span(klass, label)
  	"<span class='#{klass}'>#{label}</span>".html_safe
	end
end
