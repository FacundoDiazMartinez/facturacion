module UserActivityManager
  class MinimumStockGenerator < ApplicationService
    def initialize(product)
      @product = product
    end

    def call
      activity_for_minimum_stock_reached
    end

    private

    def activity_for_minimum_stock_reached
      UserActivity.create(
        user_id:  @product.created_by,
        photo:    "/images/product.png",
        title:    "El producto #{@product.name} posee stock bajo",
        body:     "El día #{I18n.l(Date.today)} el producto #{@product.name} alcanzó su stock mínimo, con una cantidad de #{@product.available_stock} #{@product.measurement_unit_name}.",
        link:     "/products/#{@product.id}"
      )
    end
  end
end
