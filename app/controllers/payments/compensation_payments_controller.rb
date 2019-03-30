class Payments::CompensationPaymentsController < Payments::PaymentsController
  before_action :set_compensation_payment, only: [:show, :edit, :update, :destroy]
  layout :false, except: [:index, :show]

  # GET /card_payments
  # GET /card_payments.json
  def index
    @compensation_payments = CompensationPayment.all
  end

  # GET /card_payments/1
  # GET /card_payments/1.json
  def show
    super
  end

  # GET /card_payments/new
  def new
    @compensation_payment = CompensationPayment.new
    # @invoice_client = current_user.company.clients.find(params[:invoice_client_id])
    super
  end

  # GET /card_payments/1/edit
  def edit
  end

  # POST /card_payments
  # POST /card_payments.json
  def create
    super
    @compensation_payment = CompensationPayment.new(compensation_payment_params)
    respond_to do |format|
      if @compensation_payment.save
        format.html { redirect_to @compensation_payment, notice: 'Compensation payment was successfully created.' }
        format.json { render :show, status: :created, location: @compensation_payment }
      else
        format.html { render :new }
        format.json { render json: @compensation_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /card_payments/1
  # PATCH/PUT /card_payments/1.json
  def update
    super
    respond_to do |format|
      if @compensation_payment.update(compensation_payment_params)
        format.html { redirect_to @compensation_payment, notice: 'Compensation payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @compensation_payment }
      else
        format.html { render :edit }
        format.json { render json: @compensation_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /card_payments/1
  # DELETE /card_payments/1.json
  def destroy
    @compensation_payment.destroy
    respond_to do |format|
      format.html { redirect_to @compensation_payment, notice: 'Compensation payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compensation_payment
      @compensation_payment = CompensationPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def compensation_payment_params
      params.require(:compensation_payment).permit(:total, :payment_id, :active, :asociatedClientInvoice, :observation, :concept, :client_id)
    end
end
