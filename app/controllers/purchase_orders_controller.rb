class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy, :cancel, :deliver]

  def index
    @purchase_orders = current_company.purchase_orders.includes(:supplier, :user).search_by_supplier(params[:supplier_name]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("purchase_orders.id DESC").paginate(page: params[:page])
  end

  def show
    Product.unscoped do
      @group_details = @purchase_order.purchase_order_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@purchase_order}",
        layout: 'pdf.html',
        template: 'purchase_orders/show',
        #zoom: 3.1,
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  def new
    @purchase_order = PurchaseOrder.new
  end

  def edit
  end

  def create
    @purchase_order = current_company.purchase_orders.new(purchase_order_params)
    @purchase_order.user = current_user
    if @purchase_order.save
      redirect_to edit_purchase_order_path(@purchase_order), notice: 'La órden de compra fue creada exitosamente.'
    else
      render :new
    end
  end

  def update
    if @purchase_order.editable?
      if @purchase_order.update(purchase_order_params)
        if params[:confirm] && params[:confirm] == "true"
          @purchase_order.confirmado!
          redirect_to edit_purchase_order_path(@purchase_order), notice: 'Órden de compra confirmada.'
        else
          redirect_to edit_purchase_order_path(@purchase_order), notice: 'La órden de compra fue actualizada.'
        end
      else
        render :edit
      end
    else
      redirect_to edit_purchase_order_path(@purchase_order), notice: "La órden de compra no puede ser actualizada. Estado [#{@purchase_order.state}]."
    end
  end

  def cancel
    if @purchase_order.confirmado?
      if @purchase_order.arrival_notes.empty?
        @purchase_order.anulado!
        redirect_to edit_purchase_order_path(@purchase_order), notice: 'Órden de compra anulada.'
      else
        redirect_to edit_purchase_order_path(@purchase_order), notice: "La órden de compra no puede ser anulada porque posee remitos de entrada asociados."
      end
    else
      redirect_to edit_purchase_order_path(@purchase_order), notice: "La órden de compra no puede ser anulada. Estado [#{@purchase_order.state}]."
    end
  end

  def deliver
    if @purchase_order.confirmado?
      @purchase_order = PurchaseOrderManager::MailSender.call(@purchase_order, params[:email])
      if @purchase_order.errors.empty?
        redirect_to edit_purchase_order_path(@purchase_order), notice: 'La órden de compra será enviada en unos instantes.'
      else
        render :edit
      end
    else
      redirect_to edit_purchase_order_path(@purchase_order), notice: "La órden de compra no puede ser enviada. Estado [#{@purchase_order.state}]."
    end
  end

  def destroy
    @purchase_order.destroy
    redirect_to purchase_orders_url, notice: 'La órden de compra fue eliminada exitosamente.'
  end

  # def set_supplier
  #   if params[:id]
  #     set_purchase_order
  #   else
  #     @purchase_order = PurchaseOrder.new
  #   end
  #   @supplier = current_company.suppliers.find(params[:supplier_id])
  #   @purchase_order.supplier_id = @supplier.id
  # end

  def autocomplete_product_code
    term = params[:term]
    if params[:supplier_id].blank?
      products = current_company.products.where('code ILIKE ?', "%#{term}%").order(:code).all
    else
      products = current_company.suppliers.find(params[:supplier_id]).products.where('code ILIKE ?', "%#{term}%").order(:code).all
    end
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, :value => product.code, name: product.name, price: product.cost_price, supplier_code: product.supplier_code} }
  end

  def search_product
    @products = Product.unscoped.where(active: true, company_id: current_company_id).search_by_supplier(params[:supplier_id]).search_by_category(params[:product_category_id]).paginate(page: params[:page], per_page: 10)
    render '/purchase_orders/details/search_product'
  end

  private

  def set_purchase_order
    @purchase_order = PurchaseOrder.find(params[:id])
  end

  def purchase_order_params
    params.require(:purchase_order).permit(:supplier_id, :date, :total, :user_id, :shipping, :shipping_cost, :company_id, :date, :budget,
       purchase_order_details_attributes: [:id, :quantity, :total, :_destroy, product_attributes: [:id, :code, :supplier_code, :cost_price, :name, :price] ])
  end
end
