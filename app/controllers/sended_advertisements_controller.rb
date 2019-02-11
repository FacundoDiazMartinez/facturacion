class SendedAdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:show, :new]
  layout :false, only: :create


  def new
    @sended_advertisement =  @advertisement.sended_advertisement.new()
    @clients = Client.all.map{|a| a if a.has_email?}.compact.paginate(page: params[:page], per_page: 2)
  end

  def create
    advertisement = current_user.company.advertisements.find(params[:sended_advertisement][:advertisement_id])
    @sended_advertisement = advertisement.sended_advertisement.new(sended_advertisements_params)
    pp @sended_advertisement
    pp "////////////////////////////////////////////////////////"
    respond_to do |format|
      if @sended_advertisement.save
        format.html { redirect_to advertisements_path, notice: 'La publicidad fue enviada con éxito.' }
      else
        format.html { render :index }
      end
    end
  end

  def show
  end

  private

    def sended_advertisements_params
      params.require(:sended_advertisement).permit(:advertisement_id, :clients_data)
    end

    def set_advertisement
      @advertisement = current_user.company.advertisements.find(params[:ad])
    end
end
