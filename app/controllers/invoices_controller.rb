class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = Invoice.includes(:client).search_by_client(params[:client_name]).search_by_tipo(params[:cbte_tipo]).search_by_state(params[:state]).order("invoices.created_at DESC").paginate(page: params[:page])
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: 'Invoice was successfully created.' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: 'Invoice was successfully updated.' }
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

  def create_client
    @client = current_user.company.clients.create(client_params)
    @invoice = Invoice.new(client_id: @client.id)
    respond_to do |format|
      format.js { render template: '/invoices/client/set_client.js.erb'}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:active, :client_id, :state, :total, :total_pay, :header_result, :authorized_on, :cae_due_date, :cae, :cbte_tipo, :sale_point_id, :concepto, :cbte_fch, :imp_tot_conc, :imp_op_ex, :imp_trib, :imp_neto, :imp_iva, :imp_total, :cbte_hasta, :cbte_desde, :iva_cond, :comp_number, :company_id, :user_id)
    end

    def client_params
      params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
    end
end
