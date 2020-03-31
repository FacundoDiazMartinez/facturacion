class TransferRequestsController < ApplicationController
  before_action :set_transfer_request, only: [:show, :edit, :update, :destroy, :cancel, :receive_transfer]

  def index
    @transfer_requests = current_company.transfer_requests
      .search_by_number(params[:number])
      .serach_by_transporter(params[:transporter])
      .search_by_sender(params[:from_depot_id])
      .search_by_receiver(params[:to_depot_id])
      .search_by_state(params[:state])
      .paginate(page: params[:page], per_page: 10)
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
        #zoom: 3.1,
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
    @transfer_request = current_company.transfer_requests.new(transfer_request_params)
    @transfer_request.user = current_user
    if @transfer_request.save
      redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Remito de traslado registrado."
    else
      render :new
    end
  end

  def update
    if @transfer_request.editable?
      if @transfer_request.update(transfer_request_params)
        if params[:deliver] && params[:deliver] == "true"
          @transfer_request = TransferRequestManager::Distributor.call(@transfer_request)
          if @transfer_request.errors.empty?
            redirect_to edit_transfer_request_path(@transfer_request), notice: 'El remito fue actualizado. Los productos están en camino al destino.'
          else
            # set_available_product_quantity
            render :edit
          end
        else
          redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Remito actualizado."
        end
      else
        render :new
      end
    else
      redirect_to edit_transfer_request_path(@transfer_request.id), notice: "El remito de traslado no puede ser actualizado. Estado: [#{@transfer_request.state}]"
    end
  end

  def destroy
    if @transfer_request.editable?
      if @transfer_request.destroy
        redirect_to transfer_requests_path(), notice: "Remito eliminado con éxito"
      else
        render :edit
      end
    else
      redirect_to transfer_requests_path(), notice: "El remito de traslado no puede ser eliminado. Estado: [#{@transfer_request.state}]."
    end
  end

  def cancel
    if @transfer_request.en_camino?
      TransferRequestManager::Cancelator.call(@transfer_request)
      redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Envío de productos anulado. Estado: [#{@transfer_request.state}]."
    else
      redirect_to transfer_requests_path(), notice: "El remito de traslado no puede ser eliminado. Estado: [#{@transfer_request.state}]."
    end
  end

  def receive_transfer
    if @transfer_request.en_camino?
      TransferRequestManager::Receiver.call(@transfer_request)
      redirect_to edit_transfer_request_path(@transfer_request.id), notice: "Productos recibidos en destino. Estado: [#{@transfer_request.state}]."
    else
      redirect_to edit_transfer_request_path(@transfer_request.id)
    end
  end

  private
    def transfer_request_params
      params.require(:transfer_request).permit(:number, :date, :from_depot_id, :to_depot_id, :state, :transporter_id,
        transfer_request_details_attributes: [:id, :product_id, :product_code, :quantity, :observation, :_destroy])
    end

    def set_transfer_request
      @transfer_request = current_company.transfer_requests.find(params[:id])
    end
end
