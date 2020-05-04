class Warehouses::ArrivalNotesController < ApplicationController
  before_action :set_arrival_note, only: [:show, :edit, :update, :destroy, :cancel]

  def index
    @arrival_notes = current_company.arrival_notes.joins(:purchase_order, :user).search_by_purchase_order(params[:purchase_order_number]).search_by_user(params[:user_name]).search_by_state(params[:state]).order("arrival_notes.created_at DESC").paginate(page: params[:page])
  end

  def show
    Product.unscoped do
      @group_details = @arrival_note.arrival_note_details.includes(:product).in_groups_of(20, fill_with= nil)
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@arrival_note.id}",
        layout: 'pdf.html',
        template: 'warehouses/arrival_notes/show',
        #zoom: 3.1,
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  def new
    @arrival_note = current_company.arrival_notes.new
  end

  def edit
    set_undelivered_quantities if @arrival_note.purchase_order
  end

  def create
    @arrival_note = current_company.arrival_notes.new(arrival_note_params)
    @arrival_note.user = current_user
    if @arrival_note.save
      redirect_to edit_arrival_note_path(@arrival_note), notice: "Remito registrado."
    else
      set_undelivered_quantities if @arrival_note.purchase_order
      render :new
    end
  end

  def update
    if @arrival_note.editable?
      if @arrival_note.update(arrival_note_params)
        if params[:confirm] && params[:confirm] == "true"
          @arrival_note = ArrivalNoteManager::Confirmator.call(@arrival_note)
          if @arrival_note.errors.empty?
            redirect_to edit_arrival_note_path(@arrival_note), notice: "Remito confirmado."
          else
            set_undelivered_quantities if @arrival_note.purchase_order
            render :edit
          end
        else
          redirect_to edit_arrival_note_path(@arrival_note), notice: "Remito actualizado."
        end
      else
        set_undelivered_quantities if @arrival_note.purchase_order
        render :edit
      end
    else
      redirect_to edit_arrival_note_path(@arrival_note), notice: "El remito no puede ser actualizado. Estado: [#{@arrival_note.state}]."
    end
  end

  def destroy
    if @arrival_note.editable?
      if @arrival_note.destroy
        redirect_to arrival_notes_url, notice: 'El remito fue eliminado.'
      else
        redirect_to arrival_notes_url, alert: 'No se pudo eliminar el remito.'
      end
    else
      redirect_to edit_arrival_note_path(@arrival_note), notice: "El remito no puede ser actualizado. Estado: [#{@arrival_note.state}]."
    end
  end

  def set_purchase_order
    if params[:id]
      set_arrival_note
    else
      @arrival_note = ArrivalNote.new
    end
    @arrival_note.arrival_note_details.each{ |detail| detail.mark_for_destruction  }
    @purchase_order = current_company.purchase_orders.confirmados.find(params[:purchase_order_id] || @arrival_note.purchase_order_id)
    @arrival_note.purchase_order = @purchase_order
    build_arrival_note_details(@arrival_note, @purchase_order)
  end

  def autocomplete_purchase_order
    term = params[:term]
    purchase_orders = current_company.purchase_orders.confirmados.where("number::text ILIKE ?", "%#{term}%").order(:number)
    render :json => purchase_orders.map { |po| {:id => po.id, :label => po.number, :value => po.number, :state => po.state} }
  end

  private

  def set_arrival_note
    @arrival_note =  current_company.arrival_notes.find(params[:id])
  end

  def arrival_note_params
    params.require(:arrival_note).permit(:purchase_order_id, :depot_id, :number, :state,
      arrival_note_details_attributes: [:id, :quantity, :req_quantity, :observation, :_destroy, :product_id],
      purchase_order_attributes: [:id, :state])
  end

  def build_arrival_note_details(arrival_note, purchase_order)
    purchase_order.purchase_order_details.each do |pod|
      arrival_note.arrival_note_details.build(
        product_id: pod.product_id,
        faltante: undelivered_product_quantity(purchase_order, pod.product_id, pod.quantity),
        req_quantity: pod.quantity
      )
    end
  end

  def undelivered_product_quantity(purchase_order, product_id, required_quantity = 0)
    faltante = purchase_order.arrival_notes.confirmados.includes(:arrival_note_details).where(arrival_note_details: {product_id: product_id}).pluck(:quantity).inject(required_quantity, :-)
    return 0 if faltante < 0
    faltante
  end

  def set_undelivered_quantities
    @arrival_note.arrival_note_details.each do |detail|
      detail.faltante = undelivered_product_quantity(detail.arrival_note.purchase_order, detail.product_id, detail.req_quantity)
    end
  end
end
