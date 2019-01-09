class PriceChangesController < ApplicationController
  before_action :set_price_change, only: [ :show, :apply]

  def index
    @price_changes = current_user.company.price_changes.all.paginate(page: params[:page], per_page: 15)
  end

  def new
    @price_change = PriceChange.new
  end

  def create
    @price_change = current_user.company.price_changes.new(price_change_params)
    @price_change.creator_id = current_user.id
    if @price_change.save
      redirect_to price_changes_path, notice: 'Actualización de precios registrada.'
    else
      render :new
    end
  end

  def apply
    unless @price_change.applied
      @products_with_errors = @price_change.apply_to_products current_user
      if @products_with_errors.empty?
        redirect_to @price_change, notice: "El ajuste fue aplicado con éxito."
      else
        pp @products_with_errors.first.errors.messages
        render :show, alert: "Los ajustes no fueron aplicados."
      end
    else
      redirect_to @price_change
    end
  end

  private
  def set_price_change
    @price_change = PriceChange.find(params[:id])
  end

  def price_change_params
    params.require(:price_change).permit(:name, :supplier_id, :product_category_id, :modification)
  end
end
