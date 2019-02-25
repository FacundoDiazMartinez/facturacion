class Payments::BankPaymentsController < Payments::PaymentsController
  before_action :set_bank_payment, only: [:show, :edit, :update, :destroy]
  layout :false

  # GET /bank_payments
  # GET /bank_payments.json
  def index
    @bank_payments = BankPayment.all
  end

  # GET /bank_payments/1
  # GET /bank_payments/1.json
  def show
  end

  # GET /bank_payments/new
  def new
    @bank_payment = BankPayment.new
    super
  end

  # GET /bank_payments/1/edit
  def edit
  end

  # POST /bank_payments
  # POST /bank_payments.json
  def create
    @bank_payment = BankPayment.new(bank_payment_params)

    respond_to do |format|
      if @bank_payment.save
        format.html { redirect_to @bank_payment, notice: 'Bank payment was successfully created.' }
        format.json { render :show, status: :created, location: @bank_payment }
      else
        format.html { render :new }
        format.json { render json: @bank_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_payments/1
  # PATCH/PUT /bank_payments/1.json
  def update
    respond_to do |format|
      if @bank_payment.update(bank_payment_params)
        format.html { redirect_to @bank_payment, notice: 'Bank payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_payment }
      else
        format.html { render :edit }
        format.json { render json: @bank_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_payments/1
  # DELETE /bank_payments/1.json
  def destroy
    @bank_payment.destroy
    respond_to do |format|
      format.html { redirect_to bank_payments_url, notice: 'Bank payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_payment
      @bank_payment = BankPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_payment_params
      params.fetch(:bank_payment, {})
    end
end
