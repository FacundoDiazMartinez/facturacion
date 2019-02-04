class Payments::PaymentsController < ApplicationController
	before_action :set_invoice
  	layout :false

  	def new
  		@invoice  = current_user.company.invoices.find(params[:invoice_id]) unless params[:invoice_id].blank?
    	@client   = current_user.company.clients.find(params[:client_id]) unless params[:client_id].blank?
  	end

	def set_invoice
      if params[:invoice_id].blank?
        @invoice = Invoice.new
      else
        @invoice = current_user.company.invoices.find(params[:invoice_id])
      end
    end
end