class Payments::PaymentsController < ApplicationController
	before_action :set_invoice, except: :new
	layout :false, except: :index

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

  def destroy
    @payment = current_user.company.account_movement_payments.find(params[:id])
    @receipt = @payment.account_movement.receipt
    respond_to do |format|
      if @payment.destroy
        format.html {redirect_to edit_receipt_path(@receipt.id), notice: "Pago eliminado con éxito."}
      else
        @payment.errors.full_messages.each{|e| @receipt.errors.add(:base, e)}
        format.html {render template: "/invoices/edit.html.erb"}
      end
    end
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
