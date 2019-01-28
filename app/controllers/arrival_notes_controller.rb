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
    @arrival_note = current_user.company.arrival_notes.new()
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
        format.html { redirect_to edit_arrival_note_path(@arrival_note.id), notice: 'El Remito fue creado correctamente.' }
        format.json { render :show, status: :created, location: @arrival_note }
      else
        pp @arrival_note.errors
        format.html { render :new }
        format.json { render json: @arrival_note.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    arrival_note_params_array = arrival_note_params       #arrival_note_params es un método así que no se le pueden quitar elementos
    purchase_order_attributes = arrival_note_params_array
    respond_to do |format|
      if @arrival_note.update(arrival_note_params)
        if purchase_order_attributes["state"] == "Finalizada"
          if @arrival_note.purchase_order.update(state: "Finalizada")
            message = 'Remito y su respectiva Orden de Compra fueron cerrados correctamente.'
          else
            message = 'El Remito fue actualizado correctamente, pero hubo un problema al cerrar la Orden de Compra'
          end
        end
        format.html { redirect_to edit_arrival_note_path(@arrival_note.id), notice: 'El Remito fue actualizado correctamente.' }
      else
        @arrival_note.state = @arrival_note.state_was
        format.html { render :edit }
        format.json { render json: @arrival_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arrival_notes/1
  # DELETE /arrival_notes/1.json
  def destroy
    respond_to do |format|
      if @arrival_note.destroy
        format.html { redirect_to arrival_notes_url, notice: 'El Remito fue eliminado correctamente.' }
      else
        format.html { redirect_to arrival_notes_url, alert: 'No se pudo eliminar el remito.' }
      end

    end
  end

  def set_purchase_order
    if params[:id]
      set_arrival_note
    else
      @arrival_note = ArrivalNote.new
    end
    @purchase_order = current_user.company.purchase_orders.find(params[:purchase_order_id] || @arrival_note.purchase_order_id)
    @arrival_note.purchase_order_id = @purchase_order.id
    @purchase_order.purchase_order_details.each do |pod|
      @arrival_note.arrival_note_details.new(product_id: pod.product_id, req_quantity: pod.quantity)
    end
  end

  def autocomplete_purchase_order
    term = params[:term]
    purchase_orders = current_user.company.purchase_orders.where("number::text ILIKE ? AND state = 'Aprobado'", "%#{term}%").order(:number).all
    render :json => purchase_orders.map { |po| {:id => po.id, :label => po.number, :value => po.number, :state => po.state} }
  end

  def cancel
    respond_to do |format|
      if current_user.has_stock_management_role?
        if @arrival_note.update(state: "Anulado")
          format.html {redirect_to edit_arrival_note_path(@arrival_note.id), notice: "El remito fue anulado."}
        else
          format.html{render :edit}
        end
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
      params.require(:arrival_note).permit(:purchase_order_id, :depot_id, :number, :state,
        arrival_note_details_attributes: [:id, :quantity, :observation, :_destroy,
        product_attributes: [:id, :code, :name, :price]],
        purchase_order_attributes: [:id, :state])
    end
end
