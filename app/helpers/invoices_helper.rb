module InvoicesHelper
	def invoice_state state
		case state
		when "Pendiente"
			color = 'bg-info text-white'
		when "Pagado"
			color = 'bg-warning text-dark'
		when "Confirmado"
			color = 'bg-success text-white'
		when "Anulado"
			color = 'bg-dark text-white'
		end

		return "<div class='rounded-state #{color} text-center'></div> #{state}".html_safe
	end
end
