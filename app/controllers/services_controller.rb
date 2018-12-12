class ServicesController < ApplicationController
  load_and_authorize_resource except: :autocomplete_service_code
  before_action :set_service, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update, :index]

  # GET /services
  # GET /services.json
  def index
    @services = current_user.company.services.where(tipo: "Servicio").search_by_name(params[:name]).search_by_code(params[:code]).search_by_category(params[:category]).search_with_stock(params[:stock]).paginate(page: params[:page], per_page: 9)
  end

  # GET /services/1
  # GET /services/1.json
  def show
  end

  # GET /services/new
  def new
    @service = Service.new
  end

  # GET /services/1/edit
  def edit
  end

  # POST /services
  # POST /services.json
  def create
    @service = current_user.company.services.new(service_params)
    @service.updated_by = current_user.id
    @service.created_by = current_user.id
    respond_to do |format|
      if @service.save
        format.html { redirect_to @service, notice: 'Service was successfully created.' }
        format.json { render :show, status: :created, location: @service }
      else
        format.html { render :new }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /services/1
  # PATCH/PUT /services/1.json
  def update
    @service.updated_by = current_user.id
    respond_to do |format|
      if @service.update(service_params)
        format.html { redirect_to @service, notice: 'Service was successfully updated.' }
        format.json { render :show, status: :ok, location: @service }
      else
        format.html { render :edit }
        format.json { render json: @service.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /services/1
  # DELETE /services/1.json
  def destroy
    @service.destroy
    respond_to do |format|
      format.html { redirect_to services_url, notice: 'Service was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_service
      @service = current_user.company.services.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def service_params
      params.require(:service).permit(:code, :name, :product_category_id, :cost_price, :gain_margin, :iva_aliquot, :price, :net_price, :photo)
    end
end
