class PriceChange < ApplicationRecord
  belongs_to :company
  belongs_to :supplier, optional: true
  belongs_to :product_category, optional: true
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :applicator, class_name: 'User', foreign_key: 'applicator_id', optional: true

  validates_presence_of :creator

  validates_presence_of :name, message: "Debe ingresar un nombre para la actualización de precios."
  validates_presence_of :applicator, if: :applied
  validates_presence_of :modification, message: "Debe ingresar el valor porcentual de la actualización de precios."

  #validates_numericality_of :modification, message: "El valor porcentual debe ser un valor numérico."

  validates :modification, numericality: { greater_than_or_equal_to: -50, less_than_or_equal_to: 50, message: "El valor porcentual del ajuste debe encontrarse entre -50% y 50%." }

  def supplier_name
    supplier.blank? ? "Todos" : supplier.name
  end

  def category_name
    product_category.blank? ? "Todas" : product_category.name
  end

  # PROCESOS #
  def apply_to_products applied_by
    pp self
    products_array = self.company.products.search_by_product_category_id(self.product_category_id).search_by_supplier_id(self.supplier_id)
    pp products_array
    products = products_array.to_a
    products.reject! do |product|
      product.price_modification = "#{self.modification}%"
      product.valid?
    end
    if products.any?
      pp "PRODUCT ANY"
      return products
    else
      pp products_array
      products_array.each do |product|
        product.update_attributes(price_modification: "#{self.modification}%")
      end
      self.applied = true
      self.applicator_id = applied_by.id
      self.application_date = DateTime.now
      save
      return []
    end
  end
  # PROCESOS #
end
