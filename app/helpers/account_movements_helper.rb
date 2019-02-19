module AccountMovementsHelper

	def comprobante_con_link(account_movement)
		pp "///////////////////////////////////////////////"
		pp account_movement.invoice_id
		if not account_movement.invoice_id.nil?
	        link_to "#{account_movement.cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{account_movement.invoice.comp_number}", edit_invoice_path(account_movement.invoice_id)  #Transforma Nota de Crédito A => NCA
	    else
	       	link_to  "#{account_movement.cbte_tipo.split().map{|w| w.first unless w.first != w.first.upcase}.join()} - #{account_movement.receipt.number}", edit_receipt_path(account_movement.receipt_id)
	    end
	end
end
