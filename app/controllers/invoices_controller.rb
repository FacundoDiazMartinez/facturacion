class InvoicesController < ApplicationController
  load_and_authorize_resource
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = current_user.company.invoices.joins(:client).search_by_client(params[:client_name]).search_by_number(params[:comp_number]).search_by_tipo(params[:cbte_tipo]).search_by_state(params[:state]).order("invoices.created_at DESC").paginate(page: params[:page], per_page: 9)
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    # la siguiene variable la cree para el pdf:
    Product.unscoped do
      @group_details = @invoice.invoice_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@invoice.id}",
        layout: 'pdf.html',
        template: 'invoices/show',
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  # GET /invoices/new
  def new
    DailyCash.current_daily_cash current_user.company_id
    @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
    @invoice = Invoice.new(client_id: @client.id, company_id: current_user.company_id, sale_point_id: current_user.company.sale_points.first.id, user_id: current_user.id)
  end

  # GET /invoices/1/edit
  def edit
    @client = @invoice.client
  end

  def create
    @invoice = current_user.company.invoices.new(invoice_params)
    @invoice.user_id = current_user.id
    @client = @invoice.client
    respond_to do |format|
      if @invoice.custom_save(params[:send_to_afip])
        format.html{redirect_to edit_invoice_path(@invoice.id), notice: "El comprobante fue creado con éxito."}
      else
        pp @invoice.errors
        format.html {render :new}
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    @client = @invoice.client
    @invoice.user_id = current_user.id
    respond_to do |format|
      if @invoice.update(invoice_params, params[:send_to_afip])
        format.html { redirect_to edit_invoice_path(@invoice.id), notice: 'Factura actualizada con éxito.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        pp @invoice.errors
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.destroy #TODO - solo si no esta confirmada
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Factura eliminada. Tambien se eliminaron todos sus documentos asociados.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_product_code
    term = params[:term]
    products = Product.unscoped.includes(:depots).where(active: true, company_id: current_user.company_id).where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, tipo: product.tipo, :value => product.code, name: product.name, price: product.price, measurement_unit: product.measurement_unit, depots: product.depots.map{|d| [d.id, d.name]}} }
  end

  def autocomplete_invoice_number
    term = params[:term]
    invoices = current_user.company.invoices.joins(:sale_point).select("invoices.id as invoice_id, sale_points.id, sale_points.name as sale_point_name, invoices.sale_point_id, invoices.comp_number, invoices.cbte_fch, invoices.updated_at, invoices.state, invoices.total, invoices.total_pay").where("sale_points.name || ' -  ' || invoices.comp_number ILIKE ? AND (invoices.total > invoices.total_pay) AND client_id = ? AND comp_number IS NOT NULL", "%#{term}%", params[:client_id]).order(:updated_at).all

    render :json => invoices.map { |invoice| {:id => invoice.invoice_id, :label => invoice.full_name, :value => invoice.name, total: invoice.total, faltante: invoice.total - invoice.total_pay} }
  end

  def autocomplete_associated_invoice
    term = params[:term]
    invoices = current_user.company.invoices.where('comp_number ILIKE ? AND cae IS NOT NULL', "%#{term}%")
    render :json => invoices.map{|i| {:id => i.id, :label => "Factura Nº: #{i.comp_number}", :value => i.comp_number}}
  end

  def search_product
    @products = Product.unscoped.includes(stocks: :depot).where(
    active: true, company_id: current_user.company_id).search_by_supplier_id(params[:supplier_id]).search_by_category(params[:product_category_id]).search_by_depot(params[:depot_id]).search_by_name(params[:product_name]).search_by_code(params[:product_code]).paginate(page: params[:page], per_page: 10)
    render '/invoices/detail/search_product'
  end

  def change_attributes
    if not params[:id].blank?
      set_invoice
      @invoice.cbte_tipo  = params[:cbte_tipo]
      @invoice.concepto   = params[:concepto]
    else
      @invoice = Invoice.new(cbte_tipo: params[:cbte_tipo], concepto: params[:concepto])
    end
  end

  def set_associated_invoice
    if params[:id].blank?
      @invoice = Invoice.new
    else
      set_invoice
    end
    @associated = true
    associated_invoice = current_user.company.invoices.where(comp_number: params[:associated_invoice], state: "Confirmado").first
    associated_invoice.invoice_details.each do |id|
      @invoice.invoice_details.new(id.attributes)
    end
    associated_invoice.income_payments.each do |payment|
      @invoice.income_payments.new(payment.attributes)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = current_user.company.invoices.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:active, :budget_id, :client_id, :state, :total, :total_pay, :header_result, :associated_invoice, :authorized_on, :cae_due_date, :cae, :cbte_tipo, :sale_point_id, :concepto, :cbte_fch, :imp_tot_conc, :imp_op_ex, :imp_trib, :imp_neto, :imp_iva, :imp_total, :cbte_hasta, :cbte_desde, :iva_cond, :comp_number, :company_id, :user_id, :fch_serv_desde, :fch_serv_hasta, :fch_vto_pago, :observation, :expired,
        income_payments_attributes: [:id, :type_of_payment, :total, :payment_date, :credit_card_id, :_destroy, 
          cash_payment_attributes: [:id, :total],
          card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
          bank_payment_attributes: [:id, :bank_id, :total],
          cheque_payment_attributes: [:id, :state, :expiration, :total, :observation, :origin, :entity, :number],
          retention_payment_attributes: [:id, :number, :total, :observation]
        ],
        invoice_details_attributes: [:id, :quantity, :measurement_unit, :iva_aliquot, :depot_id, :iva_amount, :price_per_unit, :bonus_percentage, :bonus_amount, :subtotal, :user_id, :depot_id, :_destroy,
        product_attributes: [:id, :code, :company_id, :name, :tipo],
        commissioners_attributes: [:id, :user_id, :percentage, :_destroy]],
        client_attributes: [:id, :name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond, :_destroy],
        tributes_attributes: [:id, :afip_id, :desc, :base_imp, :alic, :importe, :_destroy]
      )
    end

    def client_params
      params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
    end
end
