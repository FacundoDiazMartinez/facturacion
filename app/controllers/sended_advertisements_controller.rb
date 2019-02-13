class SendedAdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:new]
  before_action :set_clients, only: [:new, :create, :index]


  def new
    @sended_advertisement =  @advertisement.sended_advertisement.new()
  end

  def create
    @advertisement = current_user.company.advertisements.find(params[:sended_advertisement][:advertisement_id])
    @sended_advertisement = @advertisement.sended_advertisement.new(sended_advertisements_params)
    respond_to do |format|
      if @sended_advertisement.save
        format.html { redirect_to advertisements_path, notice: 'La publicidad fue enviada con éxito.' }
      else
        flash[:alert] = @sended_advertisement.errors.messages.map{|v, m| m}.join(", ")
        format.html { redirect_to new_sended_advertisement_path(ad: @advertisement.id)}
      end
    end
  end

  def show
    @sended_advertisement = current_user.company.sended_advertisements.find(params[:id])
  end

  private

    def set_clients
      @clients = current_user.company.clients.all.map{|a| a if a.has_email?}.compact.paginate(page: params[:page], per_page: 2)
      @unpaginated_clients = current_user.company.clients.all.map{|a| a if a.has_email?}.compact
    end

    def sended_advertisements_params
      params.require(:sended_advertisement).permit(:advertisement_id, :clients_data)
    end

    def set_advertisement
      @advertisement = current_user.company.advertisements.find(params[:ad])
    end
end
