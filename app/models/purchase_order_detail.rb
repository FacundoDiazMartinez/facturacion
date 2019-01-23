class PurchaseOrderDetail < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product

  before_validation :check_product

  accepts_nested_attributes_for :product, reject_if: :all_blank, allow_destroy: true

  after_save :set_total_to_purchase_order

  validates_presence_of :product_id, message: "Falta id de producto."
  validates_presence_of :price, message: "Falta precio unitario."
  validates_presence_of :quantity, message: "Falta especificar cantidad."
  validates_presence_of :total, message: "Total no especificado."
  validates_uniqueness_of :product_id, scope: :purchase_order_id, message: "No es posible ingresar productos iguales."

  #PROCESOS
  	def check_product
      if new_record?
        product.company_id = purchase_order.company_id
        product.save
        if not product.errors.any?
          self.price   = product.cost_price
          self.total = 	self.price * self.quantity
        end
      end
    end

    def set_total_to_purchase_order
      purchase_order.update_attribute(:total, purchase_order.sum_details)
    end

    def product_attributes=(attributes)
      if !attributes['id'].blank?
        self.product = Product.find(attributes['id'])
      end
      super
    end
  #PROCESOS
end
