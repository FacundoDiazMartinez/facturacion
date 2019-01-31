class Payments::CashPaymentsController < Payments::PaymentsController
  before_action :set_cash_payment, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new]

  # GET /cash_payments
  # GET /cash_payments.json
  def index
    @cash_payments = CashPayment.all
  end

  # GET /cash_payments/1
  # GET /cash_payments/1.json
  def show
  end

  # GET /cash_payments/new
  def new
    @cash_payment = CashPayment.new
  end

  # GET /cash_payments/1/edit
  def edit
  end

  # POST /cash_payments
  # POST /cash_payments.json
  def create
    @cash_payment = CashPayment.new(cash_payment_params)

    respond_to do |format|
      if @cash_payment.save
        format.html { redirect_to @cash_payment, notice: 'Cash payment was successfully created.' }
        format.json { render :show, status: :created, location: @cash_payment }
      else
        format.html { render :new }
        format.json { render json: @cash_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cash_payments/1
  # PATCH/PUT /cash_payments/1.json
  def update
    respond_to do |format|
      if @cash_payment.update(cash_payment_params)
        format.html { redirect_to @cash_payment, notice: 'Cash payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @cash_payment }
      else
        format.html { render :edit }
        format.json { render json: @cash_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_payments/1
  # DELETE /cash_payments/1.json
  def destroy
    @cash_payment.destroy
    respond_to do |format|
      format.html { redirect_to cash_payments_url, notice: 'Cash payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cash_payment
      @cash_payment = CashPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cash_payment_params
      params.fetch(:cash_payment, {})
    end
end
