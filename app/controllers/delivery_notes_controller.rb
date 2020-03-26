class DeliveryNotesController < ApplicationController
  before_action :set_delivery_note, only: [:show, :edit, :update, :destroy, :cancel, :confirm]

  def index
    @delivery_notes = current_company.delivery_notes.joins(:invoice, :user).without_system.search_by_invoice(params[:invoice_number]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("delivery_notes.number DESC").paginate(page: params[:page], per_page: 15)
  end

  def show
    @group_details = @delivery_note.delivery_note_details.includes(:product).in_groups_of(20, fill_with= nil)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "REMITO#{@delivery_note.number}",
        layout: 'pdf.html',
        template: 'delivery_notes/show',
        #zoom: 3.1,
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  def new
    @delivery_note = current_company.delivery_notes.new(invoice_id: params[:associated_invoice])
    @client        = current_company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
  end

  def edit
    @client = @delivery_note.client
    set_available_product_quantity
  end

  def create
    @delivery_note = current_company.delivery_notes.new(delivery_note_params)
    @delivery_note.user_id = current_user.id
    @delivery_note.generated_by = current_user.name
    @client = @delivery_note.client
    if @delivery_note.save
      redirect_to edit_delivery_note_path(@delivery_note), notice: 'Remito registrado correctamente.'
    else
      render :new
    end
  end

  def update
    @client = @delivery_note.client
    if @delivery_note.editable? && @delivery_note.update(delivery_note_params)
      if params[:confirm] && params[:confirm] == "true"
        @delivery_note = DeliveryNoteManager::Confirmator.call(@delivery_note)
        if !@delivery_note.errors.any?
          redirect_to edit_delivery_note_path(@delivery_note), notice: 'El remito fue confirmado y el inventario actualizado.'
        else
          set_available_product_quantity
          render :edit
        end
      else
        redirect_to edit_delivery_note_path(@delivery_note), notice: 'El remito actualizado correctamente.'
      end
    else
      set_available_product_quantity
      render :edit
    end
  end

  def destroy
    @delivery_note.destroy
    redirect_to delivery_notes_url, notice: 'El remito fue eliminado correctamente.'
  end

  def cancel
    @client = @delivery_note.client
    if @delivery_note.finalizado?
      @delivery_note.user = current_user
      @delivery_note = DeliveryNoteManager::Cancelator.call(@delivery_note)
      if @delivery_note.errors.empty?
        redirect_to edit_delivery_note_path(@delivery_note), notice: 'El remito fue anulado.'
      else
        set_available_product_quantity
        render :edit
      end
    else
      redirect_to edit_delivery_note_path(@delivery_note), notice: "El remito no puede ser anulado. Estado actual: [#{@delivery_note.state}]."
    end
  end

  def search_product
    @products = current_company.products.search_by_supplier(params[:supplier_id]).search_by_category(params[:product_category_id]).paginate(page: params[:page], per_page: 10)
    render '/delivery_notes/details/search_product'
  end

  def set_associated_invoice
    if params[:id]
      set_delivery_note
    else
      new
    end
    @associated_invoice     = current_company.invoices.where(id: params[:associated_invoice_id] || @delivery_note.invoice_id).first
    @client                 = @associated_invoice.client
    @delivery_note.client   = @associated_invoice.client

    build_delivery_note_details(@delivery_note, @associated_invoice)
  end

  # mover a invoices_controller
  def autocomplete_invoice
    term = params[:term]
    invoices = current_company.invoices.facturas_y_notas_debito.confirmados.pendientes_de_entrega.search_by_number(term).order(:comp_number)
    render :json => invoices.map { |invoice| { :id => invoice.id, :label => "#{invoice.name_with_comp} - #{invoice.client.name}", :value => invoice.name_with_comp, client: invoice.client.attributes } }
  end

  private

  def set_delivery_note
    @delivery_note = current_company.delivery_notes.find(params[:id])
  end

  def delivery_note_params
    params.require(:delivery_note).permit(:invoice_id, :date, :number, :client_id, :active, :state, delivery_note_details_attributes: [:id, :invoice_detail_id, :product_id, :quantity, :depot_id, :observation, :cumpliment, :_destroy])
  end

  def build_delivery_note_details(delivery_note, invoice)
    invoice.invoice_details.joins(:product).where("products.tipo = 'Producto'").each do |detail|
      dn = delivery_note.delivery_note_details.build(
        product_id: detail.product_id,
        depot_id: detail.depot_id,
        invoice_detail_id: detail.id,
        quantity: undelivered_product_quantity(detail)
      )
      dn.available_product_quantity = available_product_quantity(detail)
    end
  end

  def undelivered_product_quantity(detail)
    DeliveryNoteDetail.pendiente_de_entrega(detail)
  end

  def available_product_quantity(detail)
    available_quantity = Stock.where(product_id: detail.product_id, depot_id: detail.depot_id).pluck(:quantity).inject(0, :+)
    return available_quantity
  end

  def set_available_product_quantity
    @delivery_note.delivery_note_details.each do |detail|
      detail.available_product_quantity = available_product_quantity(detail)
    end
  end
end
