class Payments::CardPaymentsController < Payments::PaymentsController
  before_action :set_card_payment, only: [:show, :edit, :update, :destroy]
  layout :false, except: [:index, :show]

  def index
    @card_payments = current_company.card_payments.joins(:payment, :credit_card).includes(:payment, :credit_card).where(payments: {confirmed: true}).search_by_card(params[:card]).search_by_date(params[:date]).order("card_payments.created_at DESC").paginate(page: params[:page], per_page: 10)
  end

  def show
    super
  end

  def new
    @card_payment = CardPayment.new
    super
  end

  def edit
  end

  def create
    super
    @card_payment = CardPayment.new(card_payment_params)

    respond_to do |format|
      if @card_payment.save
        format.html { redirect_to [:payments, :card_payments], notice: 'Card payment was successfully created.' }
        format.json { render :show, status: :created, location: @card_payment }
      else
        format.html { render :new }
        format.json { render json: @card_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /card_payments/1
  # PATCH/PUT /card_payments/1.json
  def update
    super
    respond_to do |format|
      if @card_payment.update(card_payment_params)
        format.html { redirect_to [:payments, :card_payments], notice: 'Card payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @card_payment }
      else
        format.html { render :edit }
        format.json { render json: @card_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /card_payments/1
  # DELETE /card_payments/1.json
  def destroy
    @card_payment.destroy
    respond_to do |format|
      format.html { redirect_to [:payments, :card_payments], notice: 'Card payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_payment
      @card_payment = current_company.card_payments.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_payment_params
      params.require(:card_payment).permit(:credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total)
    end
end
