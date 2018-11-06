class PurchaseOrderDetail < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product

  before_validation :check_product
  
  accepts_nested_attributes_for :product, reject_if: :all_blank, allow_destroy: true

  #PROCESOS
  	def check_product
      if new_record?
        product.company_id = purchase_order.company_id
        product.save
        if not product.errors.any?
          self.price   = product.price
          self.total = 	self.price * self.quantity
        end
      end
    end

     def product_attributes=(attributes)
      if !attributes['id'].blank?
        self.product = Product.find(attributes['id'])
      end
      super
    end
  #PROCESOS
end
