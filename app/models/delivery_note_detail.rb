class DeliveryNoteDetail < ApplicationRecord
  belongs_to :delivery_note, optional: true
  belongs_to :product, optional: true, class_name: "ProductUnscoped"
  belongs_to :depot, optional: true


  validates_presence_of :delivery_note, message:  "El detalle debe tener asociado un remito."
  validates_presence_of :product, message:  "El detalle debe tener asociado un producto."
  validates_presence_of :depot, message:  "El detalle debe tener asociado un depoósito."

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
