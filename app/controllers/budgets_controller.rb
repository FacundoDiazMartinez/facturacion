class BudgetsController < ApplicationController
  before_action :set_budget, only: [:show, :edit, :update, :destroy, :make_sale]

  # GET /budgets
  # GET /budgets.json
  def index
    @budgets = current_user.company.budgets.search_by_user(params[:user_name]).search_by_number(params[:number]).search_by_client(params[:client_name]).paginate(per_page: 10, page: params[:page])
  end

  # GET /budgets/1
  # GET /budgets/1.json
  def show
    Product.unscoped do
      @group_details = @budget.budget_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@budget.id}",
        layout: 'pdf.html',
        template: 'budgets/show',
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  # GET /budgets/new
  def new
    @budget = Budget.new
    @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
  end

  # GET /budgets/1/edit
  def edit
    @client = @budget.client
  end

  # POST /budgets
  # POST /budgets.json
  def create
    @budget = current_user.company.budgets.new(budget_params)
    @budget.user_id = current_user.id
    @client = @budget.client
    respond_to do |format|
      if @budget.save
        format.html { redirect_to edit_budget_path(@budget.id), notice: 'El presupuesto fue creado correctamente.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /budgets/1
  # PATCH/PUT /budgets/1.json
  def update
    respond_to do |format|
      @client = @budget.client
      if @budget.update(budget_params)
        format.html { redirect_to edit_budget_path(@budget.id), notice: 'El presupuesto fue actualizado correctamente.' }
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
      format.html { redirect_to budgets_url, notice: 'El presupuesto fue eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def make_sale
    @client = @budget.client
    @invoice = Invoice.new(client_id: @client.id, company_id: current_user.company_id, sale_point_id: current_user.company.sale_points.first.id, user_id: current_user.id, total: @budget.total)
    @budget.budget_details.each do |bd|
      detail = @invoice.invoice_details.build(
        quantity: bd.quantity,
        measurement_unit: bd.measurement_unit,
        price_per_unit: bd.price_per_unit,
        bonus_percentage: bd.bonus_percentage,
        bonus_amount: bd.bonus_amount,
        subtotal: bd.subtotal,
        depot_id: bd.depot_id
      )
      detail.product = bd.product
    end
    render template: '/invoices/new.html.erb'
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