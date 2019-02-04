class AdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:show, :edit, :update, :destroy]

  def index
    @advertisements = current_user.company.advertisements.search_by_user(params[:user_name]).search_by_state(params[:state]).order("advertisements.delivery_date DESC").paginate(page: params[:page])
  end

  def show
  end

  def edit
  end

  def new
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_advertisement
      @advertisement = current_user.company.advertisements.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def advertisement_params
      params.require(:advertisement).permit(:title, :body, :image1, :delivery_date, :active, :state)
    end

end
