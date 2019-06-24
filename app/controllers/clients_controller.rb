class ClientsController < ApplicationController
  load_and_authorize_resource
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients
  # GET /clients.json
  def index
    @clients = current_user.company.clients.includes(:invoices).search_by_name(params[:name]).search_by_expired(params[:expired]).search_by_document(params[:document_number]).search_by_valid_for_account(params[:valid_for_account]).order(saldo: :desc).paginate(per_page: 10, page: params[:page])
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.json
  def create
    @client             = Client.new(client_params)
    @client.user_id     = current_user.id
    @client.company_id  = current_user.company_id

    respond_to do |format|
      if @client.save
        index
      end
      format.js { render :set_client }
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    respond_to do |format|
      @client.user_id = current_user.id
      if @client.update(client_params)
        index
      end
      format.js { render :set_client }
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Se eliminó el cliente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:name, :address, :document_type, :document_number, :iva_cond, :valid_for_account, :recharge, :payment_day, :observation, :contact_1, :contact_2, client_contacts_attributes: [:id, :name, :email, :charge, :phone, :mobile_phone, :_destroy], authorized_personals_attributes: [:id, :first_name, :last_name, :dni, :need_purchase_order])
    end
end
