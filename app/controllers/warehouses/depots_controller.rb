class Warehouses::DepotsController < ApplicationController
  before_action :set_depot, only: [:show, :edit, :update, :destroy]

  def index
    @depots = current_company.depots.search_by_name(params[:name]).search_by_availability(params[:filled]).order("depots.created_at DESC").paginate(page: params[:page], per_page: 9)
  end

  def show
    @stocks = @depot.stocks.search_by_product(params[:product_name]).search_by_state(params[:state]).paginate(per_page: 10, page: params[:page])
    @arrival_notes = @depot.arrival_notes.confirmados.limit(5)
    @delivery_notes = @depot.delivery_notes.confirmados.limit(5)
  end

  def new
    @depot = Depot.new
  end

  def edit
  end

  def create
    @depot = current_company.depots.new(depot_params)
    if @depot.save
      redirect_to depot_path(@depot), notice: 'El depósito fue registrado.'
    else
      render :new
    end
  end

  def update
    if @depot.update(depot_params)
      redirect_to depot_path(@depot), notice: 'El depósito se actualizó correctamente.'
    else
      render :edit
    end
  end

  def destroy
    @depot.destroy
     redirect_to depots_url, notice: 'El depósitio se eliminó correctamente.'
  end

  private
    def set_depot
      @depot = current_company.depots.find(params[:id])
    end

    def depot_params
      params.require(:depot).permit(:name, :active, :company_id, :stock_count, :stock_limit, :location, :filled)
    end
end
