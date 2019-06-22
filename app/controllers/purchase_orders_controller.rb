class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy, :approve, :add_payment]

  # GET /purchase_orders
  # GET /purchase_orders.json
  def index
    @purchase_orders = current_user.company.purchase_orders.joins(:supplier, :user).search_by_supplier(params[:supplier_name]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("purchase_orders.id DESC").paginate(page: params[:page])
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
    Product.unscoped do
      @group_details = @purchase_order.purchase_order_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@purchase_order.id}",
        layout: 'pdf.html',
        template: 'purchase_orders/show',
        #zoom: 3.1,
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  # GET /purchase_orders/new
  def new
    @purchase_order = PurchaseOrder.new
    Depot.check_at_least_one current_user.company_id
  end

  # GET /purchase_orders/1/edit
  def edit
  end

  # POST /purchase_orders
  # POST /purchase_orders.json
  def create
    @purchase_orders = current_user.company.purchase_orders.joins(:supplier, :user).search_by_supplier(params[:supplier_name]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("purchase_orders.created_at DESC").paginate(page: params[:page])
    @purchase_order = current_user.company.purchase_orders.new(purchase_order_params)
    @purchase_order.user_id = current_user.id
    respond_to do |format|
      if @purchase_order.save
        format.html { redirect_to edit_purchase_order_path(@purchase_order.id), notice: 'La órden de compra fue creada exitosamente.' }
      else
        format.html { render :new }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      if @purchase_order.update(purchase_order_params, params[:send_mail], params[:email])
        format.html { redirect_to edit_purchase_order_path(@purchase_order.id), notice: 'La órden de compra fue actualizada exitosamente.' }
      else
        format.html { render :edit }
        format.json { render json: @purchase_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_payment
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    @purchase_order.destroy
    respond_to do |format|
      format.html { redirect_to purchase_orders_url, notice: 'La órden de compra fue eliminada exitosamente.' }
      format.json { head :no_content }
    end
  end

  def set_supplier
    if params[:id]
      set_purchase_order
    else
      @purchase_order = PurchaseOrder.new
    end
    @supplier = current_user.company.suppliers.find(params[:supplier_id])
    @purchase_order.supplier_id = @supplier.id
  end

  def autocomplete_product_code
    term = params[:term]
    if params[:supplier_id].blank?
      products = current_user.company.products.where('code ILIKE ?', "%#{term}%").order(:code).all
    else
      products = current_user.company.suppliers.find(params[:supplier_id]).products.where('code ILIKE ?', "%#{term}%").order(:code).all
    end
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, :value => product.code, name: product.name, price: product.cost_price, supplier_code: product.supplier_code} }
  end

  def approve
    respond_to do |format|
      if current_user.has_purchase_management_role?
        @purchase_order.update_column(:state, "Aprobado")
        format.html {redirect_to '/purchase_orders', notice: "La orden de compra fue aprobada."}
      else
        format.html {render :edit, notice: "No tiene los provilegios necesarios para aprobar la orden de compra."}
      end
    end
  end

  def disapprove
    respond_to do |format|
      if current_user.has_purchase_management_role?
        @purchase_order.update_column(:state, "Desaprobado")
        format.html {redirect_to @purchase_order, notice: "La orden de compra fue aprobada."}
      else
        format.html {render :edit, notice: "No tiene los provilegios necesarios para aprobar la orden de compra."}
      end
    end
  end

  def search_product
    @products = Product.unscoped.where(active: true, company_id: current_user.company_id).search_by_supplier(params[:supplier_id]).search_by_category(params[:product_category_id]).paginate(page: params[:page], per_page: 10)
    render '/purchase_orders/details/search_product'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
      params.require(:purchase_order).permit(:state, :supplier_id, :observation, :total, :total_pay, :created_at, :user_id, :shipping, :shipping_cost, :company_id,
        expense_payments_attributes: [:id, :type_of_payment, :total, :payment_date, :credit_card_id, :_destroy,
          cash_payment_attributes: [:id, :total],
          debit_payment_attributes: [:id, :total, :bank_id],
          card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
          bank_payment_attributes: [:id, :bank_id, :total],
          cheque_payment_attributes: [:id, :state, :expiration, :issuance_date, :total, :observation, :origin, :entity, :number],
          retention_payment_attributes: [:id, :number, :total, :observation],
          compensation_payment_attributes: [:id, :concept, :total, :asociatedClientInvoice, :observation, :client_id]
        ],
         purchase_order_details_attributes: [:id, :quantity, :total, :_destroy, product_attributes:[:id, :code, :supplier_code, :cost_price, :name, :price]])
    end
end
