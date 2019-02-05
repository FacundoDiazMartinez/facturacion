class AdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:show, :edit, :update, :destroy, :cancel]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  def index
    @advertisements = current_user.company.advertisements.joins(:user).search_by_user(params[:user_name]).search_by_state(params[:state]).order("advertisements.delivery_date DESC").paginate(page: params[:page], per_page: 9)
  end

  def show
  end

  def edit
  end

  def new
    @advertisement = current_user.company.advertisements.new()
  end

  def create
    @advertisement = current_user.company.advertisements.new(advertisement_params)
    @advertisement.user_id = current_user.id
    respond_to do |format|
      if @advertisement.save
        format.html { redirect_to advertisements_path, notice: 'La publicidad fue creada con éxito.' }
        format.json { render :show, status: :created, location: @advertisement }
      else
        format.html { render :new }
        format.json { render json: @advertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @advertisement.user_id = current_user.id
    respond_to do |format|
      if @advertisement.update(advertisement_params)
        format.html { redirect_to advertisement_path(@advertisement.id), notice: 'La campaña públicitaria fue actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @advertisement }
      else
        format.html { render :edit }
        format.json { render json: @advertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @advertisement.destroy
    respond_to do |format|
      format.html { redirect_to advertisements_path, notice: 'La publicidad fué aliminada correctamente.' }
      format.json { head :no_content }
    end
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
      params.require(:advertisement).permit(:advertisement_id, :title, :body, :image1, :delivery_date)
    end

end
