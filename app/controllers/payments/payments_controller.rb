class Payments::PaymentsController < ApplicationController
	before_action :set_invoice, except: :new
	layout :false, except: :index

	def new
		if !params[:root_payment_form]
	    if !params[:client_id].nil?
	    	set_client
	      set_account_movement
	    elsif !params[:receipt_id].nil?
	      set_receipt
	      set_account_movement
			elsif !params[:purchase_order_id].nil?
				  @purchase_order = params[:purchase_order_id].blank? ? PurchaseOrder.new : current_user.company.purchase_orders.find(params[:purchase_order_id])
	    else
	      set_invoice
	    end
		else
			@payment = current_user.company.payments.unscoped.find(params[:payment_id])
		end
	end

	def edit
		if !params[:receipt_id].blank?
			@payment = current_user.company.account_movement_payments.unscoped.find(params[:id])
		else
			@payment = current_user.company.payments.unscoped.find(params[:id])
		end
		render template: "/payments/edit.js.erb"
	end

  def show
  end

  def create
  end

  def update
		if !params[:account_movement_payment].blank?
			@payment = current_user.company.account_movement_payments.unscoped.find(params[:id])
			respond_to do |format|
				if @payment.update(payment_params)
					format.html {redirect_back(fallback_location: receipt_path(@payment.account_movement.receipt_id), notice: "Pago actualizado")}
				else
					format.html {redirect_back(fallback_location: receipt_path(@payment.account_movement.receipt_id), alert: "Error al actualizar el pago. Revise por favor.")}
				end
			end
		else
			@payment = current_user.company.income_payments.unscoped.find(params[:id])
			respond_to do |format|
				if @payment.update(payment_params)
					format.html {redirect_back(fallback_location: invoice_path(@payment.invoice_id), notice: "Pago actualizado")}
				else
					format.html {redirect_back(fallback_location: invoice_path(@payment.invoice_id), alert: "Error al actualizar el pago. Revise por favor.")}
				end
			end
		end
		#@payment = current_user.company.payments.unscoped.find(params[:id])  # CHEQUEAR ESTO, agregue el unscoped porque sino no lo encuentra al pago del recibo

  end

  def destroy
    @payment = AccountMovementPayment.where(company_id: current_user.company_id).find(params[:id])
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
      @invoice = params[:invoice_id].blank? ? Invoice.new : current_user.company.invoices.unscoped.find(params[:invoice_id])
    end

    def set_client
      @client  = current_user.company.clients.find(params[:client_id])
    end

    def set_account_movement
      @account_movement = params[:account_movement_id].blank? ? AccountMovement.new() : current_user.company.account_movements.find(params[:account_movement_id])
    end

		def payment_params
				params.require(eval("#{params[:account_movement_payment].blank? ? ':payment' : ':account_movement_payment'}")).permit(:id, :type_of_payment, :total, :payment_date, :credit_card_id, :_destroy,
					cash_payment_attributes: [:id, :total],
					debit_payment_attributes: [:id, :total, :bank_id],
					card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
					bank_payment_attributes: [:id, :bank_id, :total],
					cheque_payment_attributes: [:id, :state, :expiration, :total, :observation, :origin, :entity, :number],
					retention_payment_attributes: [:id, :number, :total, :observation, :tribute],
					compensation_payment_attributes: [:id, :concept, :total, :asociatedClientInvoice, :observation, :client_id]
				)
		end
end
