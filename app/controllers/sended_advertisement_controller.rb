class SendedAdvertisementController < ApplicationController
  before_action :set_advertisement, only: [:show, :create, :new]



  def new
    @sended_advertisement =  @advertisement.sended_advertisement.new()
  end

  def create
  end

  def show
  end

  def set_advertisement
    @advertisement = current_user.company.advertisements.find(params[:ad])
  end
end
