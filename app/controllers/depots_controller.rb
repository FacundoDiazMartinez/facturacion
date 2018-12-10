class DepotsController < ApplicationController
  before_action :set_depot, only: [:show, :edit, :update, :destroy]

  # GET /depots
  # GET /depots.json
  def index
    set_depots
  end

  # GET /depots/1
  # GET /depots/1.json
  def show
    @stocks = @depot.stocks.paginate(per_page: 10, page: params[:page])
  end

  # GET /depots/new
  def new
    @depot = Depot.new
  end

  # GET /depots/1/edit
  def edit
  end

  # POST /depots
  # POST /depots.json
  def create
    @depot = current_user.company.depots.new(depot_params)

    respond_to do |format|
      if @depot.save
        set_depots
        format.html { redirect_to @depot, notice: 'Depot was successfully created.' }
        format.json { render :show, status: :created, location: @depot }
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
        set_depots
        format.html { redirect_to @depot, notice: 'Depot was successfully updated.' }
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
      format.html { redirect_to depots_url, notice: 'Depot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_depot
      @depot = current_user.company.depots.find(params[:id])
    end

    def set_depots
      @depots = current_user.company.depots.paginate(page: params[:page], per_page: 10)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def depot_params
      params.require(:depot).permit(:name, :active, :company_id, :stock_count, :stock_limit, :location, :filled)
    end
end
