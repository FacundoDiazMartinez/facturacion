class Stock < ApplicationRecord
  belongs_to :product
  belongs_to :depot

  after_save :set_stock_to_category

  STATES = ["Disponible", "Reservado"]

  def set_stock_to_category
  	product.product_category.update_column(:products_count, product.available_stock)
  end
end
