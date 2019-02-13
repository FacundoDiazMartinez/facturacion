class Payments::PaymentsController < ApplicationController
	before_action :set_invoice, except: :new

	def new
    if !params[:client_id].blank?

    	@client   = current_user.company.clients.find(params[:client_id]) 
      @account_movement = params[:account_movement_id].blank? ? AccountMovement.new() : current_user.company.account_movements.find(params[:account_movement_id])
    else
      set_invoice
    end
	end

  def show
  end

  def create
  end

  def update
  end

	def set_invoice
      if params[:invoice_id].blank?
        @invoice = Invoice.new
      else
        @invoice = current_user.company.invoices.find(params[:invoice_id])
      end
    end
end