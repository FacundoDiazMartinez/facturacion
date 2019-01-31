class Payments::PaymentsController < ApplicationController
	before_action :set_invoice
  	layout :false

	def set_invoice
      if params[:invoice_id].blank?
        @invoice = Invoice.new
      else
        @invoice = current_user.company.invoices.find(params[:invoice_id])
      end
    end
end