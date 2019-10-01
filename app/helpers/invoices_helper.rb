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
		when "Anulado parcialmente"
			color = 'bg-dark text-white'
		end

		return "<div class='rounded-state #{color} text-center'></div> #{state}".html_safe
	end

	def bordered_invoice_by_state(state)
	  case state
		when "Pendiente"
			'border-yellow'
		when "Confirmado"
			'border-green'
		when "Anulado parcialmente"
			'border-orange'
		when "Anulado"
			'border-red'
		end
	end
end
