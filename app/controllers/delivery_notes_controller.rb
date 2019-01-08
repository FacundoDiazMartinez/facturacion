class DeliveryNotesController < ApplicationController
  before_action :set_delivery_note, only: [:show, :edit, :update, :destroy]

  # GET /delivery_notes
  # GET /delivery_notes.json
  def index
    @delivery_notes = current_user.company.delivery_notes
  end

  # GET /delivery_notes/1
  # GET /delivery_notes/1.json
  def show
  end

  # GET /delivery_notes/new
  def new
    @delivery_note = DeliveryNote.new
  end

  # GET /delivery_notes/1/edit
  def edit
  end

  # POST /delivery_notes
  # POST /delivery_notes.json
  def create
    @delivery_note = DeliveryNote.new(delivery_note_params)
    @delivery_note.company_id = current_user.company_id

    respond_to do |format|
      if @delivery_note.save
        format.html { redirect_to @delivery_note, notice: 'El Remito fue creado correctamente.' }
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
    respond_to do |format|
      if @delivery_note.update(delivery_note_params)
        format.html { redirect_to @delivery_note, notice: 'El Remito fue actualizado correctamente..' }
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
      format.html { redirect_to delivery_notes_url, notice: 'El Remito fue eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_note
      @delivery_note = current_user.company.delivery_notes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_note_params
      params.require(:delivery_note).permit(:invoice_id ,:company_id, :user_id, :client_id, :number, :active, :state)
    end
end
