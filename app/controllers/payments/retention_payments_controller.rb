class Payments::RetentionPaymentsController < Payments::PaymentsController
  before_action :set_retention_payment, only: [:show, :edit, :update, :destroy]
  layout :false

  # GET /retention_payments
  # GET /retention_payments.json
  def index
    @retention_payments = RetentionPayment.all
  end

  # GET /retention_payments/1
  # GET /retention_payments/1.json
  def show
  end

  # GET /retention_payments/new
  def new
    @retention_payment = RetentionPayment.new
    super
  end

  # GET /retention_payments/1/edit
  def edit
  end

  # POST /retention_payments
  # POST /retention_payments.json
  def create
    @retention_payment = RetentionPayment.new(retention_payment_params)

    respond_to do |format|
      if @retention_payment.save
        format.html { redirect_to @retention_payment, notice: 'Retention payment was successfully created.' }
        format.json { render :show, status: :created, location: @retention_payment }
      else
        format.html { render :new }
        format.json { render json: @retention_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /retention_payments/1
  # PATCH/PUT /retention_payments/1.json
  def update
    respond_to do |format|
      if @retention_payment.update(retention_payment_params)
        format.html { redirect_to @retention_payment, notice: 'Retention payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @retention_payment }
      else
        format.html { render :edit }
        format.json { render json: @retention_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /retention_payments/1
  # DELETE /retention_payments/1.json
  def destroy
    @retention_payment.destroy
    respond_to do |format|
      format.html { redirect_to retention_payments_url, notice: 'Retention payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_retention_payment
      @retention_payment = RetentionPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def retention_payment_params
      params.fetch(:retention_payment, {})
    end
end
