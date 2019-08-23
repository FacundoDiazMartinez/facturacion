class IvaBooksController < ApplicationController
  before_action :set_iva_book, only: [:show, :edit, :update, :destroy]
  before_action :set_iva_books, only: [:index, :generate_pdf]

  # GET /iva_books
  # GET /iva_books.json
  def index
    #se establecio: before_action :set_iva_books
  end


  def generate_pdf
    @group_details = @iva_books.in_groups_of(20, fill_with= nil)
    @from = params[:from]
    @to = params[:to]

    if params[:iva_compras] == "true"
      @type = "Crédito Fiscal"
    else
      @type = "Débito Fiscal"
    end

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Libro IVA " + "(comp vtas) " + params[:from] + " hasta " + params[:to],
        layout: 'pdf.html',
        template: 'iva_books/informe',
        viewport_size: '1280x1024',
        page_size: 'A4',
        #zoom: 3.4,
        #si en local se ve mal, poner en 3.4 solo para local
        encoding:"UTF-8"
      end
    end
  end

  # # GET /iva_books/1
  # # GET /iva_books/1.json
  def show

  end

  # # GET /iva_books/new
  # def new
  #   @iva_book = IvaBook.new
  # end

  # # GET /iva_books/1/edit
  # def edit
  # end

  # # POST /iva_books
  # # POST /iva_books.json
  # def create
  #   @iva_book = current_user.company.iva_books.new(iva_book_params)

  #   respond_to do |format|
  #     if @iva_book.save
  #       format.html { redirect_to @iva_book, notice: 'Iva book was successfully created.' }
  #       format.json { render :show, status: :created, location: @iva_book }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @iva_book.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /iva_books/1
  # # PATCH/PUT /iva_books/1.json
  # def update
  #   respond_to do |format|
  #     if @iva_book.update(iva_book_params)
  #       format.html { redirect_to @iva_book, notice: 'Iva book was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @iva_book }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @iva_book.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /iva_books/1
  # # DELETE /iva_books/1.json
  # def destroy
  #   @iva_book.destroy
  #   respond_to do |format|
  #     format.html { redirect_to iva_books_url, notice: 'Iva book was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_iva_book
      @iva_book = IvaBook.find(params[:id])
    end

    def set_iva_books
      @iva_books = current_user.company.iva_books.find_by_period(params[:from], params[:to]).search_by_tipo(params[:iva_compras]).paginate(page: params[:page], per_page: 15)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def iva_book_params
      params.require(:iva_book).permit(:tipo, :invoice_id, :purchase_invoice_id, :date, :net_amount, :iva_amount, :total)
    end
end
