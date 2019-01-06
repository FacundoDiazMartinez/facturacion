class ArrivalNotesController < ApplicationController
  before_action :set_arrival_note, only: [:show, :edit, :update, :destroy, :cancel]

  # GET /arrival_notes
  # GET /arrival_notes.json
  def index
    @arrival_notes = current_user.company.arrival_notes.joins(:purchase_order, :user).search_by_purchase_order(params[:purchase_order_number]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("arrival_notes.created_at DESC").paginate(page: params[:page])
  end

  # GET /arrival_notes/1
  # GET /arrival_notes/1.json
  def show
    Product.unscoped do
      @group_details = @arrival_note.arrival_note_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@arrival_note.id}",
        layout: 'pdf.html',
        template: 'arrival_notes/show',
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  # GET /arrival_notes/new
  def new
    @arrival_note = ArrivalNote.new()
  end

  # GET /arrival_notes/1/edit
  def edit
  end

  # POST /arrival_notes
  # POST /arrival_notes.json
  def create
    @arrival_note = current_user.company.arrival_notes.new(arrival_note_params)
    @arrival_note.user_id = current_user.id

    respond_to do |format|
      if @arrival_note.save
        format.html { redirect_to '/arrival_notes', notice: 'Arrival note was successfully created.' }
        format.json { render :show, status: :created, location: @arrival_note }
      else
        format.html { render :new }
        format.json { render json: @arrival_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /arrival_notes/1
  # PATCH/PUT /arrival_notes/1.json
  def update
    respond_to do |format|
      if @arrival_note.update(arrival_note_params)
        format.html { redirect_to '/arrival_notes', notice: 'Arrival note was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @arrival_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arrival_notes/1
  # DELETE /arrival_notes/1.json
  def destroy
    @arrival_note.destroy
    respond_to do |format|
      format.html { redirect_to arrival_notes_url, notice: 'Arrival note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def set_purchase_order
    if params[:id]
      set_arrival_note
    else
      @arrival_note = ArrivalNote.new
    end
    @purchase_order = current_user.company.purchase_orders.find(params[:purchase_order_id])
    @arrival_note.purchase_order_id = @purchase_order.id
    @purchase_order.purchase_order_details.each do |pod|
      @arrival_note.arrival_note_details.new(product_id: pod.product_id, req_quantity: pod.quantity)
    end
  end

  def autocomplete_purchase_order
    term = params[:term]
    purchase_orders = current_user.company.purchase_orders.where("number::text ILIKE ? AND state = 'Aprobado'", "%#{term}%").order(:number).all
    render :json => purchase_orders.map { |po| {:id => po.id, :label => po.number, :value => po.number} }
  end

  def cancel
    respond_to do |format|
      if current_user.has_stock_management_role?
        pp "UPDATE"
        pp @arrival_note.update(state: "Anulado")
        pp @arrival_note.errors
        format.html {redirect_to edit_arrival_note_path(@arrival_note.id), notice: "El remito fue anulado."}
      else
        format.html {render :edit, notice: "No tiene los provilegios necesarios para anular el remito."}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_arrival_note
      @arrival_note =  current_user.company.arrival_notes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def arrival_note_params
      params.require(:arrival_note).permit(:purchase_order_id, :depot_id, :number, arrival_note_details_attributes: [:id, :req_quantity, :quantity, :observation, :_destroy, product_attributes: [:id, :code, :name, :price]])
    end
end
