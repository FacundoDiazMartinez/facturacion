class PaymentsController < ApplicationController
	def destroy
		if params[:purchase_order_id].blank? # >>>>>>>>  Para saber si el destroy es para un pago de factura (income) o un pago de orden de compra (expense)
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
		else
			@purchase_order = current_user.company.purchase_orders.find(params[:purchase_order_id])
			@expense_payment = @purchase_order.expense_payments.find(params[:id])
			respond_to do |format|
	  		if @expense_payment.destroy
	  			format.html {redirect_to edit_purchase_order_path(@purchase_order.id), notice: "Pago eliminado con éxito."}
	  		else
	  			@expense_payment.errors.full_messages.each{|e| @purchase_order.errors.add(:base, e)}
	  			format.html {render template: "/purchase_orders/edit.html.erb"}
	  		end
	  	end
		end
	end
end
