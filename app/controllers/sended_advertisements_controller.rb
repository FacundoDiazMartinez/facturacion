class SendedAdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:new]
  layout :false, only: :create


  def new
    @sended_advertisement =  @advertisement.sended_advertisement.new()
    @clients = current_user.company.clients.all.map{|a| a if a.has_email?}.compact.paginate(page: params[:page], per_page: 2)
    @unpaginated_clients = Client.all.map{|a| a if a.has_email?}.compact
  end

  def create
    advertisement = current_user.company.advertisements.find(params[:sended_advertisement][:advertisement_id])
    @sended_advertisement = advertisement.sended_advertisement.new(sended_advertisements_params)
    respond_to do |format|
      if @sended_advertisement.save
        format.html { redirect_to advertisements_path, notice: 'La publicidad fue enviada con éxito.' }
      else
        format.html { render :index }
      end
    end
  end

  def show
    @sended_advertisement = current_user.company.sended_advertisements.find(params[:id])
  end

  private

    def sended_advertisements_params
      params.require(:sended_advertisement).permit(:advertisement_id, :clients_data)
    end

    def set_advertisement
      @advertisement = current_user.company.advertisements.find(params[:ad])
    end
end
