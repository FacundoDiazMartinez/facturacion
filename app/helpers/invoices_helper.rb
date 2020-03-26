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

	def invoice_payments(invoice)
		if invoice.receipts.any?
			array = []
			if invoice.on_account?
				invoice.receipts.each do |receipt|
					receipt.account_movement.account_movement_payments.user_payments.each { |payment|	array << payment.payment_name }
				end
				return array.uniq.compact.join(', ')
			else
				AccountMovement.unscoped do
					invoice.income_payments.each { |payment| array << payment.payment_name }
				end
				return array.uniq.compact.join(', ')
			end
		else
			return "Cta. Cte."
		end
	end

	def invoice_comp_number(invoice)
	  invoice.comp_number.to_s.rjust(8, '0') unless invoice.comp_number.nil?
	end

	def invoice_bar_code(invoice)
		require "check_digit.rb"
		code_hash = {
			cuit: 			invoice.company.cuit,
			cbte_tipo: 	invoice.cbte_tipo.to_s.rjust(3,padstr= '0'),
			pto_venta: 	invoice.sale_point.name,
			cae: 				invoice.cae,
			vto_cae: 		invoice.cae_due_date
		}
		code 				= code_hash.values.join("")
		last_digit 	= CheckDigit.new(code).calculate
		result 			= "#{code}#{last_digit}"
		result.size.odd? ? "0" + result : result
	end
end
