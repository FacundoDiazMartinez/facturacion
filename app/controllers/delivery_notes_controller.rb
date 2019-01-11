class DeliveryNotesController < ApplicationController
  before_action :set_delivery_note, only: [:show, :edit, :update, :destroy, :cancel]

  # GET /delivery_notes
  # GET /delivery_notes.json
  def index
    @delivery_notes = current_user.company.delivery_notes.joins(:invoice, :user).without_system.search_by_invoice(params[:invoice_number]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("delivery_notes.date DESC").paginate(page: params[:page])
  end

  # GET /delivery_notes/1
  # GET /delivery_notes/1.json
  def show
  end

  # GET /delivery_notes/new
  def new
    @delivery_note = current_user.company.delivery_notes.new
    @delivery_note.set_number
    @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
  end

  # GET /delivery_notes/1/edit
  def edit
    @client = @delivery_note.client
  end

  # POST /delivery_notes
  # POST /delivery_notes.json
  def create
    @delivery_note = current_user.company.delivery_notes.new(delivery_note_params)
    @delivery_note.user_id = current_user.id
    @delivery_note.generated_by = current_user.name
    @client = @delivery_note.client
    respond_to do |format|
      if @delivery_note.save
        format.html { redirect_to edit_delivery_note_path(@delivery_note.id), notice: 'Delivery note was successfully created.' }
        format.json { render :show, status: :created, location: @delivery_note }
      else
        format.html { render :new }
        format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_notes/1
  # PATCH/PUT /delivery_notes/1.json
  def update
    @delivery_note.user_id = current_user.id
    respond_to do |format|
      if @delivery_note.update(delivery_note_params)
        format.html { redirect_to edit_delivery_note_path(@delivery_note.id), notice: 'Delivery note was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_note }
      else
        format.html { render :edit }
        format.json { render json: @delivery_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_notes/1
  # DELETE /delivery_notes/1.json
  def destroy
    @delivery_note.destroy
    respond_to do |format|
      format.html { redirect_to delivery_notes_url, notice: 'Delivery note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def cancel
    @delivery_note.user_id = current_user.id
    respond_to do |format|
      if @delivery_note.update(state: "Anulado")
        format.html { redirect_to @delivery_note, notice: 'Delivery note was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def search_product
    @products = current_user.company.products.search_by_supplier(params[:supplier_id]).search_by_category(params[:product_category_id]).paginate(page: params[:page], per_page: 10)
    render '/delivery_notes/details/search_product'
  end

  def set_associated_invoice
    if params[:id].blank? 
      @delivery_note = DeliveryNote.new 
    else
      set_delivery_note
    end
    @associated = true
    associated_invoice = current_user.company.invoices.where(id: params[:associated_invoice], state: "Confirmado").first
    associated_invoice.invoice_details.each do |id|
      pp @delivery_note.delivery_note_details.new(
        product_id: id.product_id,
        depot_id: id.depot_id,
        quantity: id.quantity
      )
    end
  end

  def autocomplete_invoice
    term = params[:term]
    invoices = current_user.company.invoices.where("comp_number ILIKE ? AND state = 'Confirmado'", "%#{term}%").order(:comp_number).all
    render :json => invoices.map { |invoice| {:id => invoice.id, :label => invoice.full_number, :value => invoice.full_number} }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_note
      @delivery_note = current_user.company.delivery_notes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_note_params
      params.require(:delivery_note).permit(:invoice_id, :date, :number, :client_id, :active, :state, delivery_note_details_attributes: [:id, :product_id, :quantity, :depot_id, :observation, :cumpliment, :_destroy])
    end
end
