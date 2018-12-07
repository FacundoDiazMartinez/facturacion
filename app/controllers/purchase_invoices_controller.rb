class PurchaseInvoicesController < ApplicationController
  before_action :set_purchase_invoice, only: [:show, :edit, :update, :destroy]

  # GET /purchase_invoices
  # GET /purchase_invoices.json
  def index
    @purchase_invoices = current_user.company.purchase_invoices.joins(:supplier, :user).search_by_supplier(params[:supplier_name]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("purchase_invoices.created_at DESC").paginate(page: params[:page])
  end

  # GET /purchase_invoices/1
  # GET /purchase_invoices/1.json
  def show
  end

  # GET /purchase_invoices/new
  def new
    @purchase_invoice = PurchaseInvoice.new
  end

  # GET /purchase_invoices/1/edit
  def edit
  end

  # POST /purchase_invoices
  # POST /purchase_invoices.json
  def create
    @purchase_invoice = current_user.company.purchase_invoices.new(purchase_invoice_params)
    @purchase_invoice.user_id = current_user.id
    respond_to do |format|
      if @purchase_invoice.save
        format.html { redirect_to @purchase_invoice, notice: 'Purchase invoice was successfully created.' }
        format.json { render :show, status: :created, location: @purchase_invoice }
      else
        format.html { render :new }
        format.json { render json: @purchase_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchase_invoices/1
  # PATCH/PUT /purchase_invoices/1.json
  def update
    respond_to do |format|
      if @purchase_invoice.update(purchase_invoice_params)
        format.html { redirect_to @purchase_invoice, notice: 'Purchase invoice was successfully updated.' }
        format.json { render :show, status: :ok, location: @purchase_invoice }
      else
        format.html { render :edit }
        format.json { render json: @purchase_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchase_invoices/1
  # DELETE /purchase_invoices/1.json
  def destroy
    @purchase_invoice.destroy
    respond_to do |format|
      format.html { redirect_to purchase_invoices_url, notice: 'Purchase invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_arrival_note_id
    term = params[:term]
    arrival_notes = current_user.company.arrival_notes.where('number::text ILIKE ?', "%#{term}%").all
    render :json => arrival_notes.map { |arr_note| {:id => arr_note.id, :label => arr_note.number, :value => arr_note.id} }
  end

  def autocomplete_purchase_order
    term = params[:term]
    purchase_orders = current_user.company.purchase_orders.where("number::text ILIKE ? AND state = 'Aprobado'", "%#{term}%").all
    render :json => purchase_orders.map { 
      |po| {:id => po.id, :label => po.number, :value => po.number, supplier_id: po.supplier_id, total: po.total} 
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_invoice
      @purchase_invoice = current_user.company.purchase_invoices.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_invoice_params
      params.require(:purchase_invoice).permit(:company_id, :user_id, :date, :arrival_note_id, :number, :supplier_id, :cbte_tipo, :net_amount, :iva_amount, :imp_op_ex, :total)
    end
end
