class SendedAdvertisementsController < ApplicationController
  before_action :set_advertisement, only: [:show, :new]
  layout :false, only: :create


  def new
    @sended_advertisement =  @advertisement.sended_advertisement.build()
    @clients = Client.all.map{|a| a if a.has_email?}.compact.paginate(page: params[:page], per_page: 2)
  end

  def create
    clients = params[:emails]
    @advertisement = current_user.company.advertisements.find(params[:advertisement_id])
    pp "/////////////////////////////////////////////////"
    pp @advertisement
    AdvertisingMailer.advertising_email(clients.split(','),@advertisement).deliver_now
    @sended_advertisement = @advertisement.sended_advertisement.new(clients_data: clients.map(&:inspect).join(','))
    @sended_advertisement.save

    # @advertisement.state = "Enviado"
    respond_to do |format|
      if @advertisement.save
        format.html { redirect_to advertisements_path, notice: 'La publicidad fue enviada con éxito.' }
        # format.json { render :show, status: :created, location: @advertisement }
        format.json { render json: {redirectUrl: advertisements_path, notice: 'La publicidad fue enviada con éxito.'} }
      else
        format.html { render :index }
        format.json { render json: @sended_advertisement.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end


  def set_advertisement
    @advertisement = current_user.company.advertisements.find(params[:ad])
  end
end
