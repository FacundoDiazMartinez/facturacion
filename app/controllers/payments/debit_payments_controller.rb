class Payments::DebitPaymentsController < Payments::PaymentsController
  before_action :set_debit_payment, only: [:show, :edit, :update, :destroy]
  layout :false

  # GET /bank_payments
  # GET /bank_payments.json
  def index
    @debit_payments = DebitPayment.all
  end

  # GET /bank_payments/1
  # GET /bank_payments/1.json
  def show
  end

  # GET /bank_payments/new
  def new
    @debit_payment = DebitPayment.new
    super
  end

  # GET /debit_payments/1/edit
  def edit
  end

  # POST /debit_payments
  # POST /debit_payments.json
  def create
    super
    @debit_payment = DebitPayment.new(debit_payment_params)

    respond_to do |format|
      if @debit_payment.save
        format.html { redirect_to @debit_payment, notice: 'Debit payment was successfully created.' }
        format.json { render :show, status: :created, location: @debit_payment }
      else
        format.html { render :new }
        format.json { render json: @debit_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /debit_payments/1
  # PATCH/PUT /debit_payments/1.json
  def update
    super
    respond_to do |format|
      if @debit_payment.update(debit_payment_params)
        format.html { redirect_to @debit_payment, notice: 'Debit payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @debit_payment }
      else
        format.html { render :edit }
        format.json { render json: @debit_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /debit_payments/1
  # DELETE /debit_payments/1.json
  def destroy
    @debit_payment.destroy
    respond_to do |format|
      format.html { redirect_to debit_payments_url, notice: 'Debit payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_debit_payment
      @debit_payment = DebitPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def debit_payment_params
      params.fetch(:debit_payment, {})
    end
end
