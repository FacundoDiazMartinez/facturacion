class InvoicesController < ApplicationController
  load_and_authorize_resource  except: [:autocomplete_product_code, :deliver, :autocomplete_invoice_number, :autocomplete_associated_invoice, :search_product]
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :deliver]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = current_user.company.invoices.joins(:client).search_by_client(params[:client_name]).search_by_number(params[:comp_number]).search_by_tipo(params[:cbte_tipo]).search_by_state(params[:state]).order("invoices.created_at DESC").paginate(page: params[:page], per_page: 9)
  end

  # GET /invoices/1
  # GET /invoices/1.json
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
          #zoom: 3.4,
          #si en local se ve mal, poner en 3.4 solo para local
          viewport_size: '1280x1024',
          page_size: 'A4',
          encoding:"UTF-8"
      end
    end

    @invoice.delete_barcode(@barcode_path)
  end

  # GET /invoices/new
  def new
    if !session[:new_invoice].blank?
      @invoice = Invoice.new(session[:new_invoice]["invoice"])
      session[:new_invoice]["invoice_details"].each do |detail|
        @invoice.invoice_details.build(detail)
      end
      session.delete(:new_invoice)
      @client = current_user.company.clients.find(@invoice.client_id)
    else
      @client = current_user.company.clients.where(document_type: "99", document_number: "0", name: "Consumidor Final", iva_cond:  "Consumidor Final").first_or_create
      @invoice = Invoice.new(client_id: @client.id, company_id: current_user.company_id, sale_point_id: current_user.company.first_sale_point, user_id: current_user.id)
    end
  end



  # GET /invoices/1/edit
  def edit
    @client = @invoice.client
  end

  def create
    @invoice = current_user.company.invoices.new(invoice_params)
    @invoice.user_id = current_user.id
    @client = @invoice.client
    respond_to do |format|
      if @invoice.custom_save(params[:send_to_afip])
        format.html{redirect_to edit_invoice_path(@invoice.id), notice: "El comprobante fue creado con éxito."}
      else
        pp @invoice.errors
        format.html {render :new}
      end
    end
  end

  def cancel
    associated_invoice = current_user.company.invoices.find(params[:id])
    atributos = associated_invoice.attributes
    @invoice = current_user.company.invoices.build(associated_invoice: associated_invoice.id)
    @invoice.attributes = atributos.except!(*["id", "state", "cbte_tipo", "header_result", "authorized_on", "cae_due_date", "cae", "cbte_fch", "comp_number", "associated_invoice", "total_pay"])
    @invoice.cbte_tipo = (associated_invoice.cbte_tipo.to_i + 2).to_s.rjust(2,padstr= '0')
    @invoice.cbte_fch = Date.today
    if @invoice.invoice_details.size == 0 && @invoice.income_payments.size == 0
      associated_invoice.invoice_details.each do |detail| # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DETALLES
        band = true
        associated_invoice.credit_notes.each do |cn|
          cn.invoice_details.each do |cn_detail|
            if (cn_detail.attributes.except!(*["id", "invoice_id", "created_at", "updated_at", "user_id"]) == detail.attributes.except!(*["id", "invoice_id", "created_at", "updated_at", "user_id"]))
              band = false
            end
          end
        end
        if band
          id = @invoice.invoice_details.build(detail.attributes.except!(*["id", "invoice_id"]))
        end
      end
      @invoice.associated_invoice = associated_invoice.id
      if associated_invoice.tributes.size > 0
        associated_invoice.tributes.each do |tribute| # >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> TRIBUTOS
          @invoice.tributes.build(tribute.attributes.except!(*["id", "invoice_id"]))
        end
      end
    end

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to edit_invoice_path(@invoice) }
      else
        format.html { redirect_to invoices_path(@invoice.id), alert: @invoice.errors.messages.values.join(". ")}
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    # if !session[:return_to].blank?
    #   session[:return_to] = session[:return_to] + "/edit"
    # end
    @client = @invoice.client
    @invoice.user_id = current_user.id
    respond_to do |format|
      if @invoice.update(invoice_params, params[:send_to_afip])
        # session.delete(:return_to)
        format.html { redirect_to edit_invoice_path(@invoice.id), notice: 'Comprobante actualizado con éxito.' }
      else
        pp @invoice.errors
        format.html { render :edit }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
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

  def deliver
    require 'barby'
    require 'barby/barcode/code_25_interleaved'
    require 'barby/outputter/png_outputter'
    @barcode_path = "#{Rails.root}/tmp/invoice#{@invoice.id}_barcode.png"
    InvoiceMailer.send_to_client(@invoice, params[:email], @barcode_path).deliver
    redirect_to edit_invoice_path(@invoice.id), notice: "Email enviado."
    @invoice.delete_barcode(@barcode_path)
  end

  def paid_invoice_with_debt
    invoice = current_user.company.invoices.where.not(cbte_tipo: Invoice::COD_NC).find(params[:id])
    result  = invoice.paid_invoice_from_client_debt
    response = result[:response]
    messages = result[:messages].join(", ")
    respond_to do |format|
      if response
        format.html {redirect_to client_account_movements_path(invoice.client_id), notice: messages}
      else
        format.html {redirect_to client_account_movements_path(invoice.client_id), alert: messages}
      end
    end
  end

  def autocomplete_product_code
    term = params[:term]
    products = Product.unscoped.includes(:depots).where(active: true, company_id: current_user.company_id).where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, tipo: product.tipo, :value => product.code, name: product.name, price: product.net_price, measurement_unit: product.measurement_unit, iva_aliquot: product.iva_aliquot || "03",depot: product.depots.order(stock_count: :desc).first.id} }
  end

  def autocomplete_invoice_number
    term = params[:term]
    invoices = current_user.company.invoices.joins(:sale_point).select("invoices.id as invoice_id, sale_points.id, sale_points.name as sale_point_name, invoices.sale_point_id, invoices.comp_number, invoices.cbte_fch, invoices.updated_at, invoices.state, invoices.total, invoices.total_pay").where("sale_points.name || ' -  ' || invoices.comp_number ILIKE ? AND (invoices.total > invoices.total_pay) AND client_id = ? AND comp_number IS NOT NULL", "%#{term}%", params[:client_id]).order(:updated_at).all

    render :json => invoices.map { |invoice| {:id => invoice.invoice_id, :label => invoice.full_name, :value => invoice.name, total: invoice.total, faltante: invoice.total - invoice.total_pay} }
  end

  def autocomplete_associated_invoice
    term = params[:term]
    client_id = params[:client_id]
    invoices = current_user.company.clients.find(client_id).invoices.where('comp_number ILIKE ? AND cae IS NOT NULL', "%#{term}%").order('comp_number DESC')
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
      @invoice = current_user.company.invoices.new
    else
      set_invoice
    end
    @associated = true
    associated_invoice = current_user.company.invoices.where(comp_number: params[:associated_invoice], state: "Confirmado").first
    if associated_invoice.is_credit_note?
      associated_invoice.invoice_details.each do |id|
        @invoice.invoice_details.new(id.attributes.except("id"))
      end
    end

    @invoice.client = associated_invoice.client
    @invoice.save
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = current_user.company.invoices.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:active, :budget_id, :client_id, :state, :total, :total_pay, :header_result, :associated_invoice, :authorized_on, :cae_due_date, :cae, :cbte_tipo, :sale_point_id, :concepto, :cbte_fch, :imp_tot_conc, :imp_op_ex, :imp_trib, :imp_neto, :imp_iva, :imp_total, :cbte_hasta, :cbte_desde, :iva_cond, :comp_number, :company_id, :user_id, :fch_serv_desde, :fch_serv_hasta, :fch_vto_pago, :observation, :expired, :bonification,
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
        tributes_attributes: [:id, :afip_id, :desc, :base_imp, :alic, :importe, :_destroy],
        bonifications_attributes: [:id, :subtotal, :observation, :percentage, :amount, :_destroy]
      )
    end

    def client_params
      params.require(:client).permit(:name, :document_type, :document_number, :birthday, :phone, :mobile_phone, :email, :address, :iva_cond)
    end
end
