class ArrivalNoteDetail < ApplicationRecord
  belongs_to :arrival_note
  belongs_to :product

  validates_presence_of     :product_id, message: "El detalle debe estar vinculado a un producto."
  validates_presence_of     :quantity, message: "El detalle debe poseer una cantidad."
  validates_numericality_of :quantity, greater_than: 0.0, message: "El detalle posee una cantidad inválida. Debe ser mayor a 0."

  attr_accessor :faltante

  def quantity
    (read_attribute("quantity") || self.req_quantity).to_f
  end

  def completed
    self.req_quantity.to_f <= self.quantity.to_f
  end

  def product_name
    product.nil? ? "" : product.name
  end

  def product_code
    product.nil? ? "" : product.code
  end

  def associates_purchase_order_detail purchase_order
    purchase_order.purchase_order_details.find_by_product_id(product_id)
  end
end
