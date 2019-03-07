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

  def create
    @credit_card = current_user.company.credit_cards.new(credit_card_params)
    respond_to do |format|
      if @credit_card.save
        format.html { redirect_to credit_cards_path, notice: 'La tarjeta se creó correctamente.' }
      else
        format.html { render :new }
        format.json { render json: @credit_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @credit_card.update(credit_card_params)
        format.html { redirect_to credit_cards_path, notice: 'La tarjeta fue actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @credit_card }
      else
        format.html { redirect_to edit_credit_card_path(@credit_card.id), alert: 'Error.'  }
        format.json { render json: @credit_card.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @credit_card.destroy
    respond_to do |format|
      format.html { redirect_to credit_cards_path, notice: 'La tarjeta fue eliminada correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    def set_credit_card
      @credit_card = current_user.company.credit_cards.find(params[:id])
    end

    def credit_card_params
      params.require(:credit_card).permit(:name, :enabled, :type_of_fee, :fav_logo,
        fees_attributes: [:id, :credit_card_id, :quantity, :coefficient, :tna, :tem, :percentage, :_destroy]
      )
    end

end
