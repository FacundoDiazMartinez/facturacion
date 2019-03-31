class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  # GET /receipts
  # GET /receipts.json
  def index
    @receipts = current_user.company.receipts.no_devolution.find_by_period(params[:from], params[:to]).search_by_client(params[:client]).paginate(page: params[:page], per_page: 15).order("created_at DESC")
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    # la siguiene variable la cree para el pdf:
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@receipt.id}",
        layout: 'pdf.html',
        template: 'receipts/show',
        zoom: 3.1,
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  # GET /receipts/new
  def new
    DailyCash.current_daily_cash current_user.company_id
    @receipt = current_user.company.receipts.new()
    @receipt.date = Date.today
    if !params[:client_id].blank?
      @client = current_user.company.clients.find(params[:client_id])
    else
      @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
    end
    AccountMovement.unscoped do
      @account_movement = AccountMovement.new()
      @account_movement_payments = @account_movement.account_movement_payments
    end
    build_account_movement
  end

  # GET /receipts/1/edit
  def edit
    @client = @receipt.client

    AccountMovement.unscoped do
      build_account_movement
      # @account_movement = @receipt.account_movement
      # @account_movement_payments = @account_movement.account_movement_payments
    end

  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = current_user.company.receipts.new(receipt_params)

    @client = @receipt.client
    respond_to do |format|
      if @receipt.save
        # if @receipt.state = "Finalizado"
        #   @receipt.touch_account_movement
        # end
        format.html { redirect_to edit_receipt_path(@receipt.id), notice: 'El recibo fue creado correctamente.' }
      else
        build_account_movement
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1
  # PATCH/PUT /receipts/1.json
  def update
    if params[:button] == "confirm"
      @receipt.state = "Finalizado"
    end
    respond_to do |format|
      if @receipt.update(receipt_params)
        if params[:button] == "confirm"
          @receipt.touch_account_movement
        end
        format.html { redirect_to edit_receipt_path(@receipt.id), notice: 'El recibo fue actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @receipt }
      else
        @client = @receipt.client
        build_account_movement
        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.json
  def destroy
    @receipt.destroy
    respond_to do |format|
      format.html { redirect_to receipts_url, notice: 'El recibo fue eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_invoice
    @client = Client.find(params[:client_id])
    term = params[:term]
    invoices = @client.invoices.where("comp_number ILIKE ? AND (state = 'Confirmado' OR state = 'Anulado parcialmente') AND total > total_pay", "%#{term}%").order(:comp_number).all
    render :json => invoices.map { |invoice| {:id => invoice.id,:label => invoice.full_number_with_debt, associated_invoices_total: invoice.confirmed_notes.sum(:total), :total_left => invoice.total_left.round(2), :total => invoice.total.round(2), :total_pay => invoice.total_pay.round(2) , :created_at => I18n.l(invoice.created_at, format: :only_date) } }
  end

  def get_cr_card_fees
    render json: current_user.company.credit_cards.find(params[:id]).fees.all.map{|a| [a.quantity, a.id]}
  end

  def get_fee_details
    render json: {fee_data: current_user.company.credit_cards.find(params[:cr_card_id]).fees.find(params[:fee_id]), fee_type: current_user.company.credit_cards.find(params[:cr_card_id]).type_of_fee }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.find(params[:id])
    end

    def build_account_movement
      @account_movement = @receipt.account_movement.nil? ? AccountMovement.new(receipt_id: @receipt.id) : @receipt.account_movement
      pp "////////////////////// ACCOUNT MOVEMENT //////////////////////////"
      pp @account_movement
      @account_movement_payments = @account_movement.account_movement_payments
      # @account_movement = @receipt.account_movement.nil? ? @receipt.build_account_movement : @receipt.account_movement
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(:client_id, :sale_point_id, :cbte_tipo, :total, :date, :concept, :state,
       receipt_details_attributes: [:id, :invoice_id, :total, :_destroy],
          account_movement_attributes: [:id, :total, :debe, :haber, :active,
          account_movement_payments_attributes: [:id, :payment_date, :type_of_payment,
          cash_payment_attributes: [:id, :total],
          card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
          bank_payment_attributes: [:id, :bank_id, :total],
          debit_payment_attributes: [:id, :bank_id, :total],
          cheque_payment_attributes: [:id, :state, :expiration, :total, :observation, :origin, :entity, :number],
          retention_payment_attributes: [:id, :number, :total, :observation, :tribute],
          compensation_payment_attributes: [:id, :concept, :total, :asociatedClientInvoice, :observation, :client_id]
          ]
        ]
      )
    end
end
