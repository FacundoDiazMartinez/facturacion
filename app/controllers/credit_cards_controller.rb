class CreditCardsController < ApplicationController
  before_action :set_credit_card, only: [:show, :edit, :update, :destroy]

  def index
    @credit_cards = current_user.company.credit_cards
  end

  def new
    @credit_card = current_user.company.credit_cards.new()
    @fee = Fee.new()
  end

  def show
  end

  def edit
  end

  def update
    #code
  end

  def destroy
    #code
  end

  private
    def set_credit_card
      @credit_card = current_user.company.credit_cards.find(params[:id])
      pp @credit_card
    end

    def credit_card_params
      params.require(:credit_card).permit(:name, :enabled,
        fees_attributes: [:credit_card_id, :quantity, :coefficient, :tna, :tem]
      )
    end

end
