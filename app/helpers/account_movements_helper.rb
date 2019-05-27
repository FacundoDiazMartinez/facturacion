module AccountMovementsHelper

	def comprobante_con_link(account_movement)
		if not account_movement.invoice_id.nil?
	        link_to "#{account_movement.cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{account_movement.invoice.sale_point.name} -  #{account_movement.invoice.comp_number}", edit_invoice_path(account_movement.invoice_id)  #Transforma Nota de Crédito A => NCA
	    else
				if account_movement.cbte_tipo == "Devolución"
					"#{account_movement.cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{account_movement.receipt.sale_point.name} -  #{account_movement.receipt.number}"
				else  # Recibo X
					link_to "#{account_movement.cbte_tipo[-1,1]} - #{account_movement.receipt.sale_point.name} - #{account_movement.receipt.number}", edit_receipt_path(account_movement.receipt_id)
	       	# link_to  "#{account_movement.cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{account_movement.receipt.number}", edit_receipt_path(account_movement.receipt_id)
				end
	    end
	end
end
