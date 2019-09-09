class InvoicesController < ApplicationController
  load_and_authorize_resource  except: [:autocomplete_product_code, :deliver, :autocomplete_invoice_number, :autocomplete_associated_invoice, :search_product]
  include DailyCashChecker
  include SalePointsGetter
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :deliver, :paid_invoice_with_debt]
  before_action :set_date_for_graphs, only: [:sales_per_month, :amount_per_month, :commissioner_per_month, :states_per_month]
  before_action :check_daily_cash, only: [:new, :create, :edit, :update]
  before_action :get_company_sale_points, only: [:new, :edit]

  def index
    @invoices = current_company.invoices.joins(:client).search_by_client(params[:client_name]).search_by_number(params[:comp_number]).search_by_tipo(params[:cbte_tipo]).search_by_state(params[:state]).order("invoices.created_at DESC").paginate(page: params[:page], per_page: 9)
  end

  def show
    # la siguiene variable la cree para el pdf:
    Product.unscoped do
      @group_details = @invoice.invoice_details.includes(:product).in_groups_of(15, fill_with= nil)
    end
    respond_to do |format|
      format.html
      format.pdf do
        @barcode_path = "#{Rails.root}/tmp/invoice#{@invoice.id}_barcode.png"
        require 'barby'
        require 'barby/barcode/code_25_interleaved'
        require 'barby/outputter/png_outputter'

        render pdf: "#{Afip::CBTE_TIPO[@invoice.cbte_tipo].split().map{|w| w.first unless w.first != w.first.upcase}.join()}" + "-" + "#{@invoice.sale_point.name}" + "-" + "#{@invoice.comp_number}" + "- Elasticos Martinez SRL",
          layout: 'pdf.html',
          template: 'invoices/show',
          show_as_html: true,
          #zoom: 3.4,
          #si en local se ve mal, poner en 3.4 solo para local
          viewport_size: '1280x1024',
          page_size: 'A4',
          encoding:"UTF-8"
      end
    end
    @invoice.delete_barcode(@barcode_path)
  end

  def new
    begin
      if !session[:new_invoice].blank?
        restore_invoice_from_session
      else
        set_new_invoice
      end
    rescue StandardError => error
      redirect_to invoices_path, alert: error.message
    end
  end

  def edit
    @client = @invoice.client
  end

  def create
    @invoice = current_company.invoices.new(invoice_params)
    @invoice.user_id = current_user.id
    @client = @invoice.client
    @invoice = InvoiceManager::TotalsSetter.call(@invoice)

    if @invoice.custom_save(params[:send_to_afip])
      redirect_to edit_invoice_path(@invoice.id), notice: "Comprobante registrado."
    else
      pp @invoice.errors
      render :new, alert: "Error al registrar el comprobante."
    end
  end

  def update
    @client = @invoice.client
    @invoice.user_id = current_user.id
    @invoice = InvoiceManager::TotalsSetter.call(@invoice)

    if @invoice.update(invoice_params, params[:send_to_afip])
      redirect_to edit_invoice_path(@invoice.id), notice: 'Comprobante actualizado con éxito.'
    else
      pp @invoice.errors
      @invoice.reload ##el reload es necesario para que los conceptos con _destroy=true se reestablezcan
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @invoice.destroy
        format.html { redirect_to invoices_url, notice: 'Comprobante eliminado. También se eliminaron todos sus documentos asociados.' }
        format.json { head :no_content }
      else
        format.hmtl { render :edit }
      end
    end
  end

  def confirm
    ##hay que hacer que la confirmación sea por separado
  end

  def cancel
    associated_invoice  = current_company.invoices.find(params[:id])
    @invoice            = InvoiceManager::Canceller.new(associated_invoice).call
    @client             = @invoice.client
    @invoice.valid?
    render :new
  end

  def deliver
    ## servicio requerido
    require 'barby'
    require 'barby/barcode/code_25_interleaved'
    require 'barby/outputter/png_outputter'
    @barcode_path = "#{Rails.root}/tmp/invoice#{@invoice.id}_barcode.png"
    InvoiceMailer.send_to_client(@invoice, params[:email], @barcode_path).deliver
    redirect_to edit_invoice_path(@invoice.id), notice: "Correo electrónico enviado."
    @invoice.delete_barcode(@barcode_path)
  end

  def paid_invoice_with_debt
    service_response = InvoiceManager::CreditPayer.call(@invoice)
    if service_response[:resultado]
      redirect_to edit_invoice_path(@invoice.id), notice: service_response[:messages].join(". ")
    else
      redirect_to client_account_movements_path(@invoice.client_id), alert: service_response[:messages].join(". ")
    end
  end

  def get_total_payed_and_left
    if params[:invoices_ids]
      invoices = Invoice.find(params[:invoices_ids])
      render :json => invoices.map{ |invoice| {
        id: invoice.id,
        total_payed: invoice.total_pay,
        real_total_left: invoice.real_total_left,
        real_total: invoice.real_total,
        total_left: invoice.total_left}
         } #{total_payed: @invoice.total_pay, total_left: @invoice.total_left}
    else
      head :no_content
    end
  end

  def autocomplete_product_code
    term = params[:term]
    products = Product.unscoped.includes(:depots).where(active: true, company_id: current_user.company_id).where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, tipo: product.tipo, :value => product.code, name: product.name, price: product.net_price, measurement_unit: product.measurement_unit, iva_aliquot: product.iva_aliquot || "03",best_depot_id: product.stocks.where(state: "Disponible").order(quantity: :desc).first.nil? ? nil : product.stocks.where(state: "Disponible").order(quantity: :desc).first.depot_id, depots_with_quantities: product.stocks.where(state: "Disponible")}}
  end

  def autocomplete_invoice_number
    term = params[:term]
    invoices = current_company.invoices.joins(:sale_point).select("invoices.id as invoice_id, sale_points.id, sale_points.name as sale_point_name, invoices.sale_point_id, invoices.comp_number, invoices.cbte_fch, invoices.updated_at, invoices.state, invoices.total, invoices.total_pay").where("sale_points.name || ' -  ' || invoices.comp_number ILIKE ? AND (invoices.total > invoices.total_pay) AND client_id = ? AND comp_number IS NOT NULL", "%#{term}%", params[:client_id]).order(:updated_at).all

    render :json => invoices.map { |invoice| {:id => invoice.invoice_id, :label => invoice.full_name, :value => invoice.full_number, total: invoice.total, faltante: invoice.total - invoice.total_pay} }
  end

  def autocomplete_associated_invoice
    term = params[:term]
    client_id = params[:client_id]
    invoices = current_company.clients.find(client_id).invoices.where(state: ["Confirmado", "Anulado parcialmente"]).where('comp_number ILIKE ? AND cae IS NOT NULL', "%#{term}%").where(cbte_tipo: ["01", "06", "11"]).order('comp_number DESC')
    render :json => invoices.map{|i| {:id => i.id, :label => "Factura Nº: #{i.comp_number}", :value => i.comp_number}}
  end

  def get_associated_invoice_details
    associated_invoice = Invoice.find(params[:id])
    invoice_details = associated_invoice.invoice_details
    render :json => invoice_details.map {
      |detail| {
        :id => detail.id,
        :product_attributes => {
          :id => detail.product.id,
          :code => detail.product.code,
          :name => detail.product.name,
          :tipo => detail.product.tipo,
          :company_id => detail.product.company_id
        },
        :quantity => detail.quantity,
        :depot_id => detail.depot_id,
        :measurement_unit => detail.measurement_unit,
        :price_per_unit => detail.price_per_unit,
        :bonus_percentage => detail.bonus_percentage ,
        :bonus_amount => detail.bonus_amount,
        :iva_amount => detail.iva_amount,
        :iva_aliquot => detail.iva_aliquot,
        :subtotal => detail.subtotal
      }
    }
  end

  def search_product
    @products = Product.unscoped.includes(stocks: :depot).where(active: true, company_id: current_user.company_id).search_by_supplier_id(params[:supplier_id]).search_by_category(params[:product_category_id]).search_by_depot(params[:filter_depot_id]).search_by_name(params[:product_name]).search_by_code(params[:product_code]).paginate(page: params[:page], per_page: 10)
    render '/invoices/detail/search_product'
  end

  def change_attributes
    if not params[:id].blank?
      set_invoice
      @invoice.cbte_tipo  = params[:cbte_tipo]
      @invoice.concepto   = params[:concepto]
    else
      @invoice = Invoice.new(cbte_tipo: params[:cbte_tipo], concepto: params[:concepto])
    end
  end

  def set_associated_invoice
    if params[:id].blank?
      @invoice = current_company.invoices.new
    else
      set_invoice
    end
    @associated = true
    associated_invoice = current_company.invoices.where(comp_number: params[:associated_invoice]).first
    if associated_invoice.is_credit_note?
      associated_invoice.invoice_details.each do |id|
        @invoice.invoice_details.new(id.attributes.except("id"))
      end
    end

    @invoice.client = associated_invoice.client
    @invoice.save
  end

  #ESTADISTICAS
  def sales_per_month
    #cbte_fch = Invoice.cbte_fch.to_date
    invoices = Invoice.where(state: "Confirmado").where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", @first_date,  @last_date).group_by_day("to_date(invoices.cbte_fch, 'dd/mm/YYYY')").count
    render json: invoices
  end

  def states_per_month
    invoices = Invoice.where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", @first_date,  @last_date).group(:state).count
    render json: invoices
  end

  def amount_per_month
    invoices = Invoice.where(state: "Confirmado").where("to_date(cbte_fch, 'dd/mm/YYYY') BETWEEN ? AND ?", @first_date,  @last_date).group_by_day("to_date(invoices.cbte_fch, 'dd/mm/YYYY')").sum(:total)
    render json: invoices
  end

  def commissioner_per_month
    invoices = Invoice.joins(:commissioners, commissioners: :user).where(commissioners: {created_at: @first_date .. @last_date}).group("users.first_name || ' ' || users.last_name").sum(:total_commission)
    render json: invoices
  end

  def sales_per_year
    invoices = Invoice.where(state:"Confirmado", cbte_fch: Date.today.at_beginning_of_year.to_s .. Date.today.at_end_of_year.to_s).group_by_month("to_date(invoices.cbte_fch, 'dd/mm/YYYY')").count
    render json: invoices
  end

  private

  def set_date_for_graphs
    month = params[:month].blank? ? Date.today.month : params[:month]
    @first_date = "01/#{month}/#{Date.today.year}".to_date
    @last_date = @first_date + 1.months - 1.days
  end

  def set_invoice
    @invoice = current_company.invoices.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:active, :budget_id, :client_id, :state, :total_pay, :header_result, :associated_invoice, :authorized_on, :cae_due_date, :cae, :cbte_tipo, :sale_point_id, :concepto, :cbte_fch, :imp_tot_conc, :imp_op_ex, :imp_trib, :imp_neto, :imp_iva, :imp_total, :cbte_hasta, :cbte_desde, :iva_cond, :comp_number, :company_id, :user_id, :fch_serv_desde, :fch_serv_hasta, :fch_vto_pago, :observation, :expired, :total, :bonification,
      income_payments_attributes: [:id, :type_of_payment, :total, :payment_date, :credit_card_id, :_destroy,
        cash_payment_attributes: [:id, :total],
        debit_payment_attributes: [:id, :total, :bank_id],
        card_payment_attributes: [:id, :credit_card_id, :subtotal, :installments, :interest_rate_percentage, :interest_rate_amount, :total],
        bank_payment_attributes: [:id, :bank_id, :ticket, :total],
        cheque_payment_attributes: [:id, :state, :expiration, :issuance_date, :total, :observation, :origin, :entity, :number],
        retention_payment_attributes: [:id, :number, :total, :observation, :tribute],
        compensation_payment_attributes: [:id, :concept, :total, :asociatedClientInvoice, :observation, :client_id]
      ],
      invoice_details_attributes: [:id, :quantity, :measurement_unit, :iva_aliquot, :depot_id, :iva_amount, :price_per_unit, :bonus_percentage, :bonus_amount, :subtotal, :user_id, :depot_id, :_destroy,
        product_attributes: [:id, :code, :company_id, :name, :tipo],
        commissioners_attributes: [:id, :user_id, :percentage, :_destroy]],
      client_attributes: [:id, :name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond, :_destroy],
      tributes_attributes: [:id, :afip_id, :base_imp, :importe, :desc, :alic, :_destroy],
      bonifications_attributes: [:id, :observation, :percentage, :amount, :subtotal, :_destroy]
    )
  end

  def client_params
    params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
  end

  def restore_invoice_from_session
    @invoice            = Invoice.new(session[:new_invoice]["invoice"])
    @invoice.company_id = current_company.id
    @client             = current_company.clients.find(@invoice.client_id)
    session[:new_invoice]["invoice_details"].map { |detail| @invoice.invoice_details.build(detail) }
    session.delete(:new_invoice)
  end

  def set_new_invoice
    @client   = current_company.clients.consumidor_final.first_or_create
    @invoice  = current_company.invoices.new.tap do |invoice|
      invoice.client_id     = @client.id
      invoice.user_id       = current_user.id
    end
  end
end
