class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]
  before_action :check_if_company_exists, only: [:new, :create]
  skip_before_action :redirect_to_company, only: [:new, :create]

  # GET /companies/1
  # GET /companies/1.json
  def show
    @users = @company.users.paginate(per_page: 5, page: params[:page])
    @activities = @company.user_activities.order(created_at: :desc).paginate(per_page: 5, page: params[:page]) unless params[:company_view] != "activities"
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies
  # POST /companies.json
  def create
    @company      = Company.new(company_params)
    respond_to do |format|
      if @company.save
        CompanyManager::Creator.call(@company, current_user)
        format.html { redirect_to @company, notice: 'Compañía creada con éxito.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        if session[:return_to].blank?
          format.html { redirect_to @company, notice: 'Compañía actualizada con éxito.' }
          format.json { render :show, status: :ok, location: @company }
        else
          pp session[:return_to]
          format.html { redirect_to session.delete(:return_to), notice: 'Ahora puede continuar con su operación.' }
          format.json { render :show, status: :ok, location: @company }
        end
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Compañía eliminada.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def company_params
      params.require(:company).permit(:email, :code, :name, :logo, :society_name, :invoice_footer, :cuit, :concepto, :moneda, :iva_cond, :country, :province_id, :locality_id, :postal_code, :address, :activity_init_date, :contact_number, :environment, :cbu, sale_points_attributes: [:id, :name, :_destroy], credit_cards_attributes: [:id, :name, :current_amount, :_destroy], banks_attributes: [:name, :cbu, :account_number, :current_amount, :id, :_destroy], default_tributes_attributes: [:id, :tribute_id, :default_aliquot, :_destroy])
    end

    def check_if_company_exists
      redirect_to company_path(current_user.company_id) unless current_user.company_id.nil?
    end
end
