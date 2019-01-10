class DeliveryNoteDetail < ApplicationRecord
  belongs_to :delivery_note
  belongs_to :product
  belongs_to :depot

  #ATRIBUTOS
  	def product_name
  		product.nil? ? "" : product.name
  	end

  	def product_code
  		product.nil? ? "" : product.code
  	end

    def product
      Product.unscoped{super}
    end
  #ATRIBUTOS
end
