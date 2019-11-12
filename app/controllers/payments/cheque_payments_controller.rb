class Payments::ChequePaymentsController < Payments::PaymentsController
  before_action :set_cheque_payment, only: [:show, :edit, :update, :destroy, :charge, :new_charge]
  before_action :set_purchase_order, only: [:show]
  layout :false, only: :new


  # GET /cheque_payments
  # GET /cheque_payments.json
  def index
    @cheque_payments = current_user.company.cheque_payments.joins(:payment).includes(:payment).search_by_number(params[:number]).search_by_client(params[:client]).search_by_date(params[:date]).order("cheque_payments.created_at DESC").paginate(page: params[:page], per_page: 10)
  end

  # GET /cheque_payments/1
  # GET /cheque_payments/1.json
  def show
  end

  # GET /cheque_payments/new
  def new
    @cheque_payment = ChequePayment.new
    super
  end
  # GET /cheque_payments/1/edit
  def edit
  end

  # POST /cheque_payments
  # POST /cheque_payments.json
  def create
    @cheque_payment = ChequePayment.new(cheque_payment_params)
    respond_to do |format|
      if @cheque_payment.save
        format.html { redirect_to @cheque_payment, notice: 'Cheque payment was successfully created.' }
        format.json { render :show, status: :created, location: @cheque_payment }
      else
        format.html { render :new }
        format.json { render json: @cheque_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cheque_payments/1
  # PATCH/PUT /cheque_payments/1.json
  def update
    respond_to do |format|
      if @cheque_payment.update(cheque_payment_params)
        format.html { redirect_to [:payments, :cheque_payments], notice: 'Cheque payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @cheque_payment }
      else
        format.html { render :edit }
        format.json { render json: @cheque_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cheque_payments/1
  # DELETE /cheque_payments/1.json
  def destroy
    @cheque_payment.destroy
    respond_to do |format|
      format.html { redirect_to [:payments, :cheque_payments], notice: 'Cheque payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def new_charge

  end

  def charge
    respond_to do |format|
      if @cheque_payment.charge_amount(params, current_user.company_id)
        format.html { redirect_to [:payments, :cheque_payments], notice: "Cobro registrado con éxito"}
      else
        format.html { redirect_to [:payments, :cheque_payments], alert: "Error al registrar el cobro"}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cheque_payment
      @cheque_payment = ChequePayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cheque_payment_params
      params.require(:cheque_payment).permit(:state, :expiration, :total, :observation, :origin, :entity, :number)
    end

    def set_purchase_order
      @purchase_order = params[:purchase_order_id].blank? ? PurchaseOrder.new : current_user.company.purchase_orders.unscoped.find(params[:purchase_order_id])
    end
end
