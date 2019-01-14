class DeliveryNoteDetail < ApplicationRecord
  belongs_to :delivery_note, optional: true
  belongs_to :product, optional: true, class_name: "ProductUnscoped"
  belongs_to :depot, optional: true


  validates_presence_of :delivery_note, message:  "El detalle debe tener asociado un remito."
  validates_presence_of :product, message:  "El detalle debe tener asociado un producto."
  validates_presence_of :depot, message:  "El detalle debe tener asociado un depoósito."

  after_validation  :adjust_product_stock, if: Proc.new{|detail| pp detail.quantity_changed? && detail.delivery_note.state != "Anulado" && !detail.new_record?}

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

  def adjust_product_stock
    difference = quantity.to_f - quantity_was.to_f
    if difference > 0
      self.product.remove_stock(quantity: difference, depot_id: self.arrival_note.depot_id)
    else
      self.product.add_stock(quantity: -difference, depot_id: self.arrival_note.depot_id)
    end
  end
end
