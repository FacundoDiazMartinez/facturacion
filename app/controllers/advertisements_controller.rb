class AdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update, :index]

  def index
    @advertisements = current_user.company.advertisements.search_by_user(params[:user_name]).search_by_state(params[:state]).order("advertisements.delivery_date DESC").paginate(page: params[:page])
  end

  def show
  end

  def edit
  end

  def new
    @advertisement = current_user.company.advertisements.new()
  end

  def cancel
    @advertisement.user_id = current_user.id
    respond_to do |format|
      if @advertisement.update(state: "Anulado")
        format.html { redirect_to advertisements_path, notice: 'La publicidad se actualizó correctamente.' }
      else
        format.html { render :edit }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_advertisement
      @advertisement = current_user.company.advertisements.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def advertisement_params
      params.require(:advertisement).permit(:title, :body, :image1, :delivery_date)
    end

end
