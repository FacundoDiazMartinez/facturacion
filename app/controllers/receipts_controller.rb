class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  # GET /receipts
  # GET /receipts.json
  def index
    @receipts = current_user.company.receipts.no_devolution.find_by_period(params[:from], params[:to]).search_by_client(params[:client]).paginate(page: params[:page], per_page: 15)
  end

  # GET /receipts/1
  # GET /receipts/1.json
  def show
    # la siguiene variable la cree para el pdf:

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "#{@receipt.id}",
        layout: 'pdf.html',
        template: 'receipts/show',
        viewport_size: '1280x1024',
        page_size: 'A4',
        encoding:"UTF-8"
      end
    end
  end

  # GET /receipts/new
  def new
    @receipt = current_user.company.receipts.new()
    @receipt.date = Date.today
    @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
  end

  # GET /receipts/1/edit
  def edit
    @client = @receipt.client
  end

  # POST /receipts
  # POST /receipts.json
  def create
    @receipt = current_user.company.receipts.new(receipt_params)
    @client = @receipt.client
    respond_to do |format|
      if @receipt.save
        format.html { redirect_to receipts_path(), notice: 'El recibo fue creado correctamente.' }
      else
        format.html { render :new }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1
  # PATCH/PUT /receipts/1.json
  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: 'El recibo fue actualizado correctamente.' }
        format.json { render :show, status: :ok, location: @receipt }
      else
        format.html { render :edit }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1
  # DELETE /receipts/1.json
  def destroy
    @receipt.destroy
    respond_to do |format|
      format.html { redirect_to receipts_url, notice: 'El recibo fue eliminado correctamente.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_invoice
    term = params[:term]
    invoices = current_user.company.invoices.where("comp_number ILIKE ? AND state = 'Confirmado'", "%#{term}%").order(:comp_number).all
    render :json => invoices.map { |invoice| {:id => invoice.id, :label => invoice.full_number, :total => invoice.imp_total, client: invoice.client.attributes} }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def receipt_params
      params.require(:receipt).permit(:invoice_id, :client_id, :sale_point_id, :number, :active, :total, :date, :concept, :company_id)
    end
end
