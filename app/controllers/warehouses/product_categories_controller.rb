class Warehouses::ProductCategoriesController < ApplicationController
  before_action :set_product_category, only: [:show, :edit, :update, :destroy]

  def index
    @product_categories = current_user.company.product_categories.search_by_name(params[:name]).search_by_supplier(params[:supplier]).order(name: "ASC").paginate(page: params[:page], per_page: 5)
  end

  def show
  end

  def new
    @product_category = ProductCategory.new
  end

  def edit
  end

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
    def set_product_category
      @product_category = current_user.company.product_categories.find(params[:id])
    end

    def product_category_params
      params.require(:product_category).permit(:name, :iva_aliquot, :supplier_id)
    end
end
