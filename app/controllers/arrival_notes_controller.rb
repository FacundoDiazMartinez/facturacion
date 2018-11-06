class ArrivalNotesController < ApplicationController
  before_action :set_arrival_note, only: [:show, :edit, :update, :destroy]

  # GET /arrival_notes
  # GET /arrival_notes.json
  def index
    @arrival_notes = ArrivalNote.all
  end

  # GET /arrival_notes/1
  # GET /arrival_notes/1.json
  def show
  end

  # GET /arrival_notes/new
  def new
    @arrival_note = ArrivalNote.new
  end

  # GET /arrival_notes/1/edit
  def edit
  end

  # POST /arrival_notes
  # POST /arrival_notes.json
  def create
    @arrival_note = ArrivalNote.new(arrival_note_params)

    respond_to do |format|
      if @arrival_note.save
        format.html { redirect_to @arrival_note, notice: 'Arrival note was successfully created.' }
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
        format.html { redirect_to @arrival_note, notice: 'Arrival note was successfully updated.' }
        format.json { render :show, status: :ok, location: @arrival_note }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_arrival_note
      @arrival_note = ArrivalNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def arrival_note_params
      params.require(:arrival_note).permit(:company_id, :purchase_order_id, :user_id, :active, :state)
    end
end
