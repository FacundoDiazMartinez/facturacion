class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :confirm]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = current_user.company.invoices.joins(:client).search_by_client(params[:client_name]).search_by_tipo(params[:cbte_tipo]).search_by_state(params[:state]).order("invoices.created_at DESC").paginate(page: params[:page])
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
    @invoice = Invoice.create(client_id: @client.id, company_id: current_user.company_id, sale_point_id: current_user.company.sale_points.first.id, user_id: current_user.id)
  end

  # GET /invoices/1/edit
  def edit
    @client = @invoice.client
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params, params[:send_to_afip])
        format.html { redirect_to edit_invoice_path(@invoice.id), notice: 'Invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_product_code
    term = params[:term]
    products = current_user.company.products.where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, :value => product.code, name: product.name, price: product.price, measurement_unit: product.measurement_unit} }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = current_user.company.invoices.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:active, :client_id, :state, :total, :total_pay, :header_result, :authorized_on, :cae_due_date, :cae, :cbte_tipo, :sale_point_id, :concepto, :cbte_fch, :imp_tot_conc, :imp_op_ex, :imp_trib, :imp_neto, :imp_iva, :imp_total, :cbte_hasta, :cbte_desde, :iva_cond, :comp_number, :company_id, :user_id, payments_attributes: [:id, :type_of_payment, :total, :_destroy], invoice_details_attributes: [:id, :quantity, :measurement_unit, :price_per_unit, :bonus_percentage, :bonus_amount, :subtotal, :_destroy, product_attributes: [:id, :code, :company_id, :measurement_unit, :price, :name]], client_attributes: [:id, :name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond, :_destroy] )
    end

    def client_params
      params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
    end
end
