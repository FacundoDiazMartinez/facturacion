class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :depot

  after_save :set_stock_to_category
  after_save :set_stock_to_depot
  after_save :set_stock_to_product

  STATES = ["Disponible", "Reservado", "Entregado"]

  def set_stock_to_category
  	product.product_category.update_column(:products_count, product.available_stock) unless product.product_category.nil?
  end

  def set_stock_to_depot
  	depot.update_column(:stock_count, product.available_stock )
  end

  def set_stock_to_product
    product.set_available_stock
  end
end
