class IncomePaymentsController < ApplicationController
  before_action :set_invoice
  before_action :set_income_payment, only: [:update]

  def create
    ActiveRecord::Base.transaction do
      income_payment = @invoice.income_payments.new(income_payment_params)
      @income_payment = PaymentManager::IncomePaymentPreprocessor.call(income_payment)

      if @income_payment.save
        @invoice = InvoiceManager::TotalsSetter.call(@invoice)
        @invoice.save!
        redirect_to edit_invoice_path(@invoice), notice: 'Pago registrado.'
      else
        pp @income_payment.errors
        redirect_to edit_invoice_path(@invoice), alert: 'Error al registrar el pago.'
      end
    rescue StandardError => error
      pp error.inspect
      redirect_to edit_invoice_path(@invoice), alert: "Error al registrar el pago. Error: #{error.inspect}"
    end
  end

  def update
    # code
  end

  private
  def set_invoice
    @invoice = Invoice.find(params[:income_payment][:invoice_id])
  end

  def set_income_payment
    @income_payment = @invoice.income_payments.find(params[:id])
  end

  def income_payment_params
    params.require(:income_payment).permit( :id, :invoice_id, :type_of_payment, :total, :payment_date, :credit_card_id,
      cash_payment_attributes: [:id, :total],
      debit_payment_attributes: [:id, :total, :bank_id],
      card_payment_attributes: [:id, :credit_card_id, :subtotal, :fee_id, :total],
      bank_payment_attributes: [:id, :bank_id, :ticket, :total],
      cheque_payment_attributes: [:id, :state, :expiration, :issuance_date, :total, :observation, :origin, :entity, :number],
      retention_payment_attributes: [:id, :number, :total, :observation, :tribute],
      compensation_payment_attributes: [:id, :concept, :total, :asociatedClientInvoice, :observation, :client_id]
    )
  end
end
