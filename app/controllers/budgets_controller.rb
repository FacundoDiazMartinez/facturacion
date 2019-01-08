class BudgetsController < ApplicationController
  before_action :set_budget, only: [:show, :edit, :update, :destroy]

  # GET /budgets
  # GET /budgets.json
  def index
    @budgets = current_user.company.budgets.search_by_user(params[:user_name]).search_by_number(params[:number]).search_by_client(params[:client_name]).paginate(per_page: 10, page: params[:page])
  end

  # GET /budgets/1
  # GET /budgets/1.json
  def show
  end

  # GET /budgets/new
  def new
    @budget = Budget.new
  end

  # GET /budgets/1/edit
  def edit
  end

  # POST /budgets
  # POST /budgets.json
  def create
    @budget = current_user.company.budgets.new(budget_params)
    @budget.user_id = current_user.id
    respond_to do |format|
      if @budget.save
        format.html { redirect_to @budget, notice: 'Budget was successfully created.' }
        format.json { render :show, status: :created, location: @budget }
      else
        pp @budget.errors
        format.html { render :new }
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /budgets/1
  # PATCH/PUT /budgets/1.json
  def update
    respond_to do |format|
      if @budget.update(budget_params)
        format.html { redirect_to @budget, notice: 'Budget was successfully updated.' }
        format.json { render :show, status: :ok, location: @budget }
      else
        format.html { render :edit }
        format.json { render json: @budget.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /budgets/1
  # DELETE /budgets/1.json
  def destroy
    @budget.destroy
    respond_to do |format|
      format.html { redirect_to budgets_url, notice: 'Budget was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_client
    term = params[:term]
    clients = current_user.company.clients.where('LOWER(name) ILIKE ?', "%#{term}%").all
    render :json => clients.map { |client| {id: client.id, label: client.name, value: client.name} }
  end

  def autocomplete_product_code
    term = params[:term]
    products = Product.unscoped.includes(:depots).where(active: true, company_id: current_user.company_id).where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, tipo: product.tipo, :value => product.code, name: product.name, price: product.price, measurement_unit: product.measurement_unit, depots: product.depots.map{|d| [d.id, d.name]}} }
  end

  def search_product
    @products = Product.unscoped.where(active: true, company_id: current_user.company_id).search_by_supplier(params[:supplier_id]).search_by_category(params[:product_category_id]).search_by_depot(params[:depot_id]).paginate(page: params[:page], per_page: 10)
    render '/budgets/detail/search_product'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_budget
      @budget = current_user.company.budgets.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def budget_params
      params.require(:budget).permit(:number, :expiration_date, :total, :active, :client_id, :reserv_stock,
        budget_details_attributes: [:id, :product_id, :product_name, :depot_id, :price_per_unit, :measurement_unit, :quantity, :bonus_percentage, :bonus_amount, :subtotal, :_destroy])
    end
end
