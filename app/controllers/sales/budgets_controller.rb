class Sales::BudgetsController < ApplicationController
  before_action :set_budget, only: [:show, :edit, :update, :confirm, :cancel, :destroy]

  def index
    @budgets = current_company.budgets.includes(:user, :client).search_by_state(params[:budget_state]).search_by_number(params[:number]).search_by_client(params[:client_name]).search_by_stock(params[:reserv_stock]).order(number: :desc).paginate(per_page: 15, page: params[:page])
  end

  def show
    Product.unscoped do
      @group_details = @budget.budget_details.includes(:product).in_groups_of(20, fill_with= nil)
    end
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "P#{@budget.number} Elasticos M&M Srl",
          layout: 'pdf.html',
          template: 'sales/budgets/show',
          #zoom: 3.1,
          viewport_size: '1280x1024',
          page_size: 'A4',
          encoding:"UTF-8"
      end
    end
  end

  def new
    @budget = current_company.budgets.new()
    set_client
    @budget.expiration_date = @budget.expiration_date || Date.today + 30.days
    @budget.state = "Válido"
  end

  def edit
    set_client
  end

  def create
    @budget      = current_company.budgets.new(budget_params)
    @budget.user = current_user
    @client      = @budget.client
    if @budget.save
      redirect_to edit_budget_path(@budget.id), notice: 'El presupuesto fue registrado.'
    else
      render :new
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to edit_budget_path(@budget.id), notice: 'El presupuesto fue actualizado.'
    else
      set_client
      render :edit
    end
  end

  def confirm
    if @budget.editable?
      @budget = BudgetManager::Confirmator.call(@budget)
      if @budget.errors.empty? && @budget.confirmado?
        redirect_to edit_budget_path(@budget), notice: "El presupuesto fue confirmado."
      else
        set_client
        render :edit
      end
    end
  end

  def cancel
    if @budget.confirmado?
      @budget = BudgetManager::Cancelator.call(@budget)
      if @budget.anulado?
        redirect_to edit_budget_path(@budget), notice: "El presupuesto fue anulado."
      else
        set_client
        render :edit
      end
    end
  end

  def destroy
    @budget.destroy
    redirect_to budgets_url, notice: 'El presupuesto fue eliminado.'
  end

  def autocomplete_client
    term = params[:term]
    clients = current_company.clients.where('LOWER(name) ILIKE ?', "%#{term}%").all
    render :json => clients.map { |client| {id: client.id, label: client.name, value: client.name} }
  end

  def autocomplete_product_code
    term = params[:term]
    products = Product.unscoped.includes(:depots).where(active: true, company_id: current_company.id).where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, tipo: product.tipo, :value => product.code, name: product.name, price: product.net_price, measurement_unit: product.measurement_unit, depot: product.depots.order(stock_count: :desc).first.id, iva_aliquot: product.iva_aliquot || "03"} }
  end

  def search_product
    @products = Product.unscoped.where(active: true, company_id: current_company.id).search_by_supplier(params[:supplier_id]).search_by_category(params[:product_category_id]).search_by_depot(params[:depot_id]).paginate(page: params[:page], per_page: 10)
    render '/sales/budgets/detail/search_product'
  end

  private

  def set_budget
    @budget = current_company.budgets.find(params[:id])
  end

  def set_client
    @client = @budget.client || current_company.clients.consumidor_final.first_or_create
  end

  def budget_params
    params.require(:budget).permit(:expiration_date, :state, :observation, :internal_observation, :total, :client_id, :reserv_stock,
      budget_details_attributes: [:id, :product_id, :product_name, :depot_id, :price_per_unit, :measurement_unit, :quantity, :bonus_percentage, :bonus_amount, :subtotal, :iva_aliquot, :iva_amount, :_destroy])
  end
end
