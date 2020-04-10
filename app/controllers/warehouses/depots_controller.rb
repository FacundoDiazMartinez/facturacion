class Warehouses::DepotsController < ApplicationController
  before_action :set_depot, only: [:show, :edit, :update, :destroy]

  def index
    @depots = current_company.depots.search_by_name(params[:name]).search_by_availability(params[:filled]).order("depots.created_at DESC").paginate(page: params[:page], per_page: 9)
  end

  def show
    @stocks = @depot.stocks.search_by_product(params[:product_name]).search_by_state(params[:state]).paginate(per_page: 10, page: params[:page])
  end

  def new
    @depot = Depot.new
  end

  def edit
  end

  def create
    @depot = current_company.depots.new(depot_params)
    set_depots
    respond_to do |format|
      if @depot.save
        if !session[:return_to].blank?
          format.html { redirect_to @depot, notice: 'El depósito fue registrado.' }
          format.json { render :show, status: :created, location: @depot }
        else
          format.html { redirect_to session.delete(:return_to), notice: 'Ahora puede continuar con su operación.'}
          format.json { render :show, status: :created, location: @depot }
        end

      else
        format.html { render :new }
        format.json { render json: @depot.errors, status: :unprocessable_entity }
      end
      format.js     { render :set_depot }
    end
  end

  # PATCH/PUT /depots/1
  # PATCH/PUT /depots/1.json
  def update
    respond_to do |format|
      if @depot.update(depot_params)
        format.html { redirect_to @depot, notice: 'El depósito se actualizó correctamente.' }
        format.json { render :show, status: :ok, location: @depot }
      else
        format.html { render :edit }
        format.json { render json: @depot.errors, status: :unprocessable_entity }
      end
      format.js     { render :set_depot }
    end
  end

  # DELETE /depots/1
  # DELETE /depots/1.json
  def destroy
    @depot.destroy
    respond_to do |format|
      format.html { redirect_to depots_url, notice: 'El depósitio se eliminó correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_depot
      @depot = current_company.depots.find(params[:id])
    end

    def set_depots
      @depots = current_company.depots.paginate(page: params[:page], per_page: 10)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def depot_params
      params.require(:depot).permit(:name, :active, :company_id, :stock_count, :stock_limit, :location, :filled)
    end
end
