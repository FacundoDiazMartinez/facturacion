class ProductsController < ApplicationController
  load_and_authorize_resource except: :autocomplete_product_code
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update, :index]
  before_action :set_date_for_graphs, only: [:top_ten_products_per_month, :top_ten_sales_per_month]
  # GET /products
  # GET /products.json
  def index
    @products = current_user.company.products.where(tipo: "Producto").search_by_name(params[:name]).search_by_code(params[:code]).search_by_category(params[:category]).search_with_stock(params[:stock]).order(name: :asc).paginate(page: params[:page], per_page: 15)
  end

  # GET /products/1
  # GET /products/1.json
  def show
    #@stocks = @product.stocks.where(active: true).paginate(page: params[:page], per_page: 5)
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  def edit_multiple
    if params[:product_ids] && params[:product_ids].any?
      @products = Product.find(params[:product_ids])
    else
      redirect_to products_path(view: 'list'), alert: "Debe seleccionar al menos 1 producto."
    end
  end

  def update_multiple
    @products = Product.find(params[:product_ids])
    ## elimina del vector los productos correctamente actualizados
    @products.reject! do |product|
      ## añade el usuario que actualiza y rechaza las actualizaciones con valores vacios
      product.updated_by = current_user.id
      product.update_attributes(update_multiple_product_params.reject { |k,v| v.blank? })
    end
    if @products.empty?
      redirect_to products_path(view: 'list'), notice: "#{ params[:product_ids].count.to_s } productos fueron actualizados."
    else
      render "edit_multiple"
    end
  end

  # POST /products
  # POST /products.json
  def create
    @product = current_user.company.products.new(product_params)
    @product.updated_by = current_user.id
    @product.created_by = current_user.id
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'El producto fue creado con éxito.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      @product.updated_by = current_user.id
      if @product.update(product_params)
        format.html { render :show, notice: 'El producto fue actualizado con éxito.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Se elimino correctamente el producto.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_product_code
    term = params[:term]
    products = Product.unscoped.where(active: true, company_id: current_user.company_id).where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, :value => product.code, name: product.name, price: product.price} }
  end

  def import
    result = Product.save_excel(params[:file], params[:supplier_id], current_user, params[:depot_id], params[:type_of_movement])
    respond_to do |format|
      format.html { redirect_to products_path, notice: 'Los productos están siendo cargados. Le avisaremos cuando termine el proceso.' }
    end
  end

  def export
    #Se utiliza el parametro empty en true cuando se quiere descargar el formato del excel solamente.
    @products = params[:empty] ? [] : current_user.company.products
    respond_to do |format|
      format.xlsx
    end
  end

  def product_category
    category = current_user.company.product_categories.find(params[:category_id])
    render :json => [{iva: category.iva_aliquot}]
  end

  #ESTADISTICAS
  def top_ten_products_per_month
    pp @first_date
    pp @last_date
    company = current_user.company_id
    pp Invoice.joins(invoice_details: :product).where( state: "Confirmado", cbte_fch: @first_date .. @last_date)
    pp chart_data = Invoice.joins(invoice_details: :product).where(company_id: company, state: "Confirmado", cbte_fch: @first_date.to_s .. @last_date.to_s).map{|inv| inv.invoice_details}.reduce(:+).group_by{|det| det.product}.map{|product, registros| [product.name, registros.map{|reg| reg.quantity}.reduce(:+).to_f]}
    chart_data = chart_data.sort_by{|a| a.last}.last(10)
    render json: chart_data
  end

  def top_ten_products_per_year
    company = current_user.company_id
    chart_data = Invoice.joins(invoice_details: :product).where(company_id: company, state: "Confirmado", cbte_fch: Date.today.at_beginning_of_year.to_s .. Date.today.at_end_of_year.to_s).map{|inv| inv.invoice_details}.reduce(:+).group_by{|det| det.product}.map{|product, registros| [product.name, registros.map{|reg| reg.quantity}.reduce(:+).to_f]}
    chart_data = chart_data.sort_by{|a| a.last}.last(10)
    render json: chart_data
  end

  def top_ten_sales_per_month
    company = current_user.company_id
    chart_data = Invoice.joins(invoice_details: :product).where(company_id: company, state: "Confirmado", cbte_fch: @first_date.to_s .. @last_date.to_s).map{|inv| inv.invoice_details}.reduce(:+).group_by{|det| det.product}.map{|product, registros| [product.name, registros.map{|reg| reg.subtotal.to_i}.reduce(:+).to_f]}
    chart_data = chart_data.sort_by{|a| a.last}.last(10)
    render json: chart_data
  end

  #ESTADISTICAS

  private
    def set_date_for_graphs
      month = params[:month].blank? ? Date.today.month : params[:month]
      @first_date = "01/#{month}/#{Date.today.year}".to_date
      @last_date = @first_date + 1.months - 1.days
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = current_user.company.products.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:product_id, :code, :name, :supplier_code, :product_category_id, :cost_price, :gain_margin, :iva_aliquot, :price, :net_price, :photo, :measurement, :measurement_unit, :supplier_id, :minimum_stock, :recommended_stock, stocks_attributes: [:id, :state, :quantity, :depot_id, :_destroy, :active])
    end

    def update_multiple_product_params
      params[:product].permit(:price_modification, :active)
    end

    def update_prices_product_params

    end
end
