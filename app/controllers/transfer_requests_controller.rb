class TransferRequestsController < ApplicationController
  before_action :set_transfer_request, only: [:show, :edit, :update, :destroy, :send_transfer, :receive_transfer]

  def index
    @transfer_requests = current_user.company.transfer_requests.paginate(page: params[:page], per_page: 10)
  end

  def show
    Product.unscoped do
      @group_details = @transfer_request.transfer_request_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@transfer_request.id}",
        layout: 'pdf.html',
        template: 'transfer_requests/show',
        zoom: 3.1,
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  def new
    @transfer_request = TransferRequest.new
  end

  def edit
  end

  def create
    @transfer_request = current_user.company.transfer_requests.new(transfer_request_params)
    @transfer_request.user_id = current_user.id
    respond_to do |format|
      if @transfer_request.save
        format.html {redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Remito creado exitosamente"}
      else
        format.html {render :new}
      end
    end
  end

  def update
    respond_to do |format|
      if @transfer_request.update(transfer_request_params)
        format.html {redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Remito actualizado exitosamente"}
      else
        format.html {render :new}
      end
    end
  end

  def destroy
    respond_to do |format|
      if @transfer_request.destroy
        format.html { redirect_to transfer_requests_path(), notice: "Remito eliminado con éxito"}
      else
        format.html { render :edit }
      end
    end
  end

  def send_transfer
    @transfer_request.update(sended_at: Time.now, sended_by: current_user.id, state: "Enviado")
    @transfer_request.register_sended_transfer
    redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Se registro el envio del remito"
  end

  def receive_transfer
    @transfer_request.update(received_at: Time.now, received_by: current_user.id, state: "Recibido")
    @transfer_request.register_received_transfer
    redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Se registro la recepción del remito"
  end

  private
    def transfer_request_params
      params.require(:transfer_request).permit(:number, :date, :from_depot_id, :to_depot_id, :observation, :state, :transporter_id,
        transfer_request_details_attributes: [:id, :product_id, :product_code, :quantity, :observatiom, :_destroy])
    end

    def set_transfer_request
      @transfer_request = current_user.company.transfer_requests.find(params[:id])
    end
end
