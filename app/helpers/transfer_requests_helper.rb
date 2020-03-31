module TransferRequestsHelper
  def transfer_request_state_helper transfer_request
    case transfer_request.state
    when 'Pendiente'
      	label_span('badge badge-pill badge-warning', 'Pendiente')
    when 'En tránsito'
      	label_span('badge badge-pill badge-info', 'En tránsito')
  	when 'Anulado'
   		label_span('badge badge-pill badge-danger', 'Anulado')
    when 'Finalizado'
     	label_span('badge badge-pill badge-success', 'Finalizado')
    end
	end

	def label_span(klass, label)
  	"<span class='#{klass}'>#{label}</span>".html_safe
	end
end
