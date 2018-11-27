class ProductsController < ApplicationController
  load_and_authorize_resource except: :autocomplete_product_code
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]
  # GET /products
  # GET /products.json
  def index
    @products = current_user.company.products.all.paginate(page: params[:page], per_page: 9)
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @stocks = @product.stocks.paginate(page: params[:page], per_page: 5)
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = current_user.company.products.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
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
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
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
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def autocomplete_product_code
    term = params[:term]
    products = current_user.company.products.where('code ILIKE ?', "%#{term}%").order(:code).all
    render :json => products.map { |product| {:id => product.id, :label => product.full_name, :value => product.code, name: product.name, price: product.price} }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = current_user.company.products.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:code, :name, :product_category_id, :cost_price, :gain_margin, :iva_aliquot, :price, :net_price, :photo, :measurement_unit)
    end
end
