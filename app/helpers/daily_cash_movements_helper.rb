module DailyCashMovementsHelper

	def user_with_link movement
		if movement.user_id.blank?
			movement.user_name
		else
			link_to movement.user_name, user_path(movement.user_id)
		end
	end

	def comprobante_con_link_dcm(daily_cash_movement)
		if not daily_cash_movement.payment.nil?
			if not daily_cash_movement.payment.invoice_id.nil?
				if not daily_cash_movement.payment.invoice.comp_number.nil?
		        	link_to "#{Afip::CBTE_TIPO[daily_cash_movement.payment.invoice.cbte_tipo].split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{daily_cash_movement.payment.invoice.sale_point.name} -  #{daily_cash_movement.payment.invoice.comp_number}", edit_invoice_path(daily_cash_movement.payment.invoice_id)  #Transforma Nota de Crédito A => NCA
		    	else
		    		link_to "#{Afip::CBTE_TIPO[daily_cash_movement.payment.invoice.cbte_tipo].split().map{|w| w.first unless w.first != w.first.upcase}.join()} - Sin confirmar", edit_invoice_path(daily_cash_movement.payment.invoice_id)  #Transforma Nota de Crédito A => NCA
		    	end
		    else
					if not daily_cash_movement.payment.purchase_order_id.nil?
						link_to "OC - #{daily_cash_movement.payment.purchase_order.number}", edit_purchase_order_path(daily_cash_movement.payment.purchase_order_id)
					else  # Recibo X
						if not daily_cash_movement.payment.account_movement.receipt_id.nil?
							link_to "#{daily_cash_movement.associated_document}", edit_receipt_path(daily_cash_movement.payment.account_movement.receipt_id)
						end
					end
		    end
		end
	end
end
