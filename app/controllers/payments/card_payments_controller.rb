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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card_payment
      @card_payment = current_company.card_payments.find(params[:id])
    end
end
