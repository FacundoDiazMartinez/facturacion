class Purchases::PurchaseInvoicesController < ApplicationController
  before_action :set_purchase_invoice, only: [:show, :edit, :update, :destroy]

  def index
    @purchase_invoices = current_company.purchase_invoices.joins(:supplier, :user).search_by_supplier(params[:supplier_name]).search_by_user(params[:user_name]).order("purchase_invoices.created_at DESC").paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def new
    @purchase_invoice = PurchaseInvoice.new
  end

  def edit
  end

  def create
    @purchase_invoice = current_company.purchase_invoices.new(purchase_invoice_params)
    @purchase_invoice.user_id = current_user.id
    if @purchase_invoice.save
      redirect_to purchase_invoices_path, notice: 'Comprobante de compra cargado correctamente.'
    else
      render :new
    end
  end

  def update
    if @purchase_invoice.update(purchase_invoice_params)
      redirect_to purchase_invoices_path, notice: 'Comprobante de compra actualizado correctamente.'
    else
      render :edit
    end
  end

  def destroy
    @purchase_invoice.destroy
    redirect_to purchase_invoices_url, notice: 'Comprobante de compra eliminado correctamente.'
  end

  def autocomplete_arrival_note_id
    term = params[:term]
    arrival_notes = current_company.arrival_notes.where('number::text ILIKE ?', "%#{term}%").all
    render :json => arrival_notes.map { |arr_note| {:id => arr_note.id, :label => arr_note.number, :value => arr_note.id} }
  end

  def autocomplete_purchase_order
    term = params[:term]
    purchase_orders = current_company.purchase_orders.confirmados.where("number::text ILIKE ?", "%#{term}%").all
    render :json => purchase_orders.map {
      |po| { :id => po.id, :label => po.number, :value => po.number, supplier_id: po.supplier_id, total: po.total }
    }
  end

  private

  def set_purchase_invoice
    @purchase_invoice = current_company.purchase_invoices.find(params[:id])
  end

  def purchase_invoice_params
    params.require(:purchase_invoice).permit(:date, :number, :supplier_id, :cbte_tipo, :percep, :net_amount, :iva_amount, :imp_op_ex, :total, :purchase_order_id, :cae)
  end
end
