class ProductPriceHistory < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :user, foreign_key: "created_by"

  after_create :set_create_activity, if: Proc.new{|pph| pph.percentage != 0 && (pph.product.created_at != pph.product.updated_at)}

  #PROCESOS
  	def set_create_activity
  		UserActivity.create_for_product_price_history self
  	end

  	def old_price
  		(100 * price) / (100 + percentage)
  	end
  #PROCESOS
end
