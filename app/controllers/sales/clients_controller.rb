class Sales::ClientsController < ApplicationController
  load_and_authorize_resource
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = current_company.clients.includes(:invoices).search_by_name(params[:name]).search_by_expired(params[:expired]).search_by_document(params[:document_number]).search_by_valid_for_account(params[:valid_for_account]).order(saldo: :desc).paginate(per_page: 10, page: params[:page])
  end

  def show
    @account_movements = @client.account_movements.order("created_at ASC").last(10).paginate()
  end

  def new
    @client = Client.new
  end

  def edit
  end

  def create
    @client          = Client.new(client_params)
    @client.user     = current_user
    @client.company  = current_company
    if @client.save
      redirect_to clients_path, notice: "Cliente registrado."
    else
      render :new
    end
  end

  def update
    @client.user = current_user
    if @client.update(client_params)
      redirect_to clients_path, notice: "Cliente registrado."
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Se eliminó el cliente.' }
      format.json { head :no_content }
    end
  end

  private
    def set_client
      @client = Client.find(params[:id])
    end

    def client_params
      params.require(:client).permit(:name, :address, :document_type, :document_number, :iva_cond, :valid_for_account, :recharge, :payment_day, :observation, :contact_1, :contact_2, :enabled, :enabled_observation, client_contacts_attributes: [:id, :name, :email, :charge, :phone, :mobile_phone, :_destroy], authorized_personals_attributes: [:id, :first_name, :last_name, :dni, :need_purchase_order])
    end
end
