class ProductCategoriesController < ApplicationController
  before_action :set_product_category, only: [:show, :edit, :update, :destroy]

  # GET /product_categories
  # GET /product_categories.json
  def index
    @product_categories = current_user.company.product_categories.search_by_name(params[:name]).search_by_supplier(params[:supplier]).order(name: "ASC").paginate(page: params[:page], per_page: 5)
  end

  # GET /product_categories/1
  # GET /product_categories/1.json
  def show
  end

  # GET /product_categories/new
  def new
    @product_category = ProductCategory.new
  end

  # GET /product_categories/1/edit
  def edit
  end

  # POST /product_categories
  # POST /product_categories.json
  def create
    @product_category = current_user.company.product_categories.new(product_category_params)

    respond_to do |format|
      if @product_category.save
        index

        format.html { redirect_to product_categories_path, notice: 'La categoría de productos fue creada correctamente.' }
        format.json { render :show, status: :created, location: @product_category }
      else
        format.html { render :new }
        format.json { render json: @product_category.errors, status: :unprocessable_entity }
      end
      format.js     { render :set_category }
    end
  end

  # PATCH/PUT /product_categories/1
  # PATCH/PUT /product_categories/1.json
  def update
    respond_to do |format|
      if @product_category.update(product_category_params)
        index
        format.html { redirect_to product_categories_path, notice: 'La categoría de productos fue actualizada correctamente.' }
        format.json { render :show, status: :ok, location: @product_category }
      else
        format.html { render :edit }
        format.json { render json: @product_category.errors, status: :unprocessable_entity }
      end
      format.js     { render :set_category }
    end
  end

  # DELETE /product_categories/1
  # DELETE /product_categories/1.json
  def destroy
    if @product_category.products.empty?
      @product_category.destroy
      respond_to do |format|
        format.html { redirect_to product_categories_url, notice: 'La categoría de productos fue eliminada correctamente.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to product_categories_url, notice: 'No puede eliminar una categoría con productos asociados.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_category
      @product_category = current_user.company.product_categories.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_category_params
      params.require(:product_category).permit(:name, :iva_aliquot, :supplier_id)
    end
end
