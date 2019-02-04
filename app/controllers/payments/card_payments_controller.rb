class Payments::CardPaymentsController < Payments::PaymentsController
  before_action :set_card_payment, only: [:show, :edit, :update, :destroy]

  # GET /card_payments
  # GET /card_payments.json
  def index
    @card_payments = CardPayment.all
  end

  # GET /card_payments/1
  # GET /card_payments/1.json
  def show
  end

  # GET /card_payments/new
  def new
    @card_payment = CardPayment.new
    super
  end

  # GET /card_payments/1/edit
  def edit
  end

  # POST /card_payments
  # POST /card_payments.json
  def create
    @card_payment = CardPayment.new(card_payment_params)

    respond_to do |format|
      if @card_payment.save
        format.html { redirect_to @card_payment, notice: 'Card payment was successfully created.' }
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
    respond_to do |format|
      if @card_payment.update(card_payment_params)
        format.html { redirect_to @card_payment, notice: 'Card payment was successfully updated.' }
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
      format.html { redirect_to card_payments_url, notice: 'Card payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_payment
      @card_payment = CardPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_payment_params
      params.fetch(:card_payment, {})
    end
end
