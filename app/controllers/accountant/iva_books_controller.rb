class Accountant::IvaBooksController < ApplicationController
  before_action :set_iva_book, only: [:show, :edit, :update, :destroy]
  before_action :set_iva_books, only: [:index, :generate_pdf]

  def index
    #se establecio: before_action :set_iva_books
  end

  def generate_pdf
    @group_details = @iva_books.in_groups_of(10, fill_with= nil)
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
        template: 'accountant/iva_books/informe',
        viewport_size: '1280x1024',
        page_size: 'A4',
        orientation: 'Landscape',
        #zoom: 3.4,
        encoding:"UTF-8"
      end
    end
  end

  def export
    if params[:iva_compras] == "true"
      tipo = "Compras"
      @iva_books = current_company.iva_books.joins(:purchase_invoice).includes(purchase_invoice: :supplier).search_by_tipo(params[:iva_compras]).find_by_period(params[:from], params[:to])
    else
      tipo = "Ventas"
      @iva_books = current_company.iva_books.joins(:invoice).includes(invoice: :client).includes(invoice: :sale_point).includes(invoice: :bonifications).find_by_period(params[:from], params[:to]).search_by_tipo(params[:iva_compras])
    end
    respond_to do |format|
      format.xlsx {
        render xlsx: "export.xlsx.axlsx", disposition: "attachment", filename: "Libro-IVA-#{tipo}-Desde:#{params[:from]}-Hasta:#{params[:to]}.xlsx"
      }
    end
  end

  def show

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_iva_book
      @iva_book = IvaBook.find(params[:id])
    end

    def set_iva_books
      @iva_books = current_company.iva_books.find_by_period(params[:from], params[:to]).search_by_tipo(params[:iva_compras]).paginate(page: params[:page], per_page: 15)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def iva_book_params
      params.require(:iva_book).permit(:tipo, :invoice_id, :purchase_invoice_id, :date, :net_amount, :iva_amount, :total)
    end
end
