class PaymentsController < ApplicationController
	def destroy
		@payment = current_user.company.income_payments.find(params[:id])
	  	@invoice = @payment.invoice
	  	respond_to do |format|
	  		if @payment.destroy
	  			format.html {redirect_to edit_invoice_path(@invoice.id), notice: "Pago eliminado con éxito."}
	  		else
	  			@payment.errors.full_messages.each{|e| @invoice.errors.add(:base, e)}
	  			format.html {render template: "/invoices/edit.html.erb"}
	  		end
	  	end
	end
end
