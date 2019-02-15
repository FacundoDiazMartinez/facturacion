class Payments::PaymentsController < ApplicationController
	before_action :set_invoice, except: :new

	def new
    if !params[:client_id].nil?
    	set_client
      set_account_movement
    elsif !params[:receipt_id].nil?
      set_receipt
      set_account_movement
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

  private

    def set_receipt
      @receipt = params[:receipt_id].blank? ? Receipt.new : current_user.company.receipts.find(params[:receipt_id])
    end

  	def set_invoice
      @invoice = params[:invoice_id].blank? ? Invoice.new : current_user.company.invoices.find(params[:invoice_id])
    end

    def set_client
      @client  = current_user.company.clients.find(params[:client_id])
    end

    def set_account_movement
      @account_movement = params[:account_movement_id].blank? ? AccountMovement.new() : current_user.company.account_movements.find(params[:account_movement_id])
    end
end