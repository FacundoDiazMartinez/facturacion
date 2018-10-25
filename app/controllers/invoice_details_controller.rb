class InvoiceDetailsController < ApplicationController
	before_action :set_invoice_detail, only: [:destroy]

	def destroy
		pp @invoice = @invoice_detail.invoice
		respond_to do |format|
			if @invoice_detail.destroy
				format.html { redirect_to edit_invoice_path(@invoice.id), notice: "Detalle eliminado exitosamente."}
				format.json { render :edit, status: :created, location: @invoice }
	    	else
	        	format.html { redirect_to edit_invoice_path(@invoice.id)}
	        	format.json { render json: @invoice_detail.errors, status: :unprocessable_entity }
	        end
	    end
	end

	protected
		def set_invoice_detail
			@invoice_detail = current_user.company.invoices.find(params[:invoice_id]).invoice_details.find(params[:id])
		end
end