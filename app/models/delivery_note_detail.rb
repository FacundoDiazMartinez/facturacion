class DeliveryNoteDetail < ApplicationRecord
  belongs_to :delivery_note, optional: true
  belongs_to :product, optional: true, class_name: "ProductUnscoped"
  belongs_to :depot, optional: true
  has_many :invoice_details, through: :delivery_note


  validates_presence_of :delivery_note, message:  "El concepto debe tener asociado un remito."
  validates_presence_of :product, message:  "El concepto debe tener asociado un producto."
  validates_presence_of :depot, message:  "El concepto debe tener asociado un depósito."

  after_validation :adjust_product_stock, if: Proc.new{|detail| detail.quantity_changed? && detail.delivery_note.state != "Anulado" && detail.new_record?}

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

    def _destroy
      @_destroy
    end

    def _destroy=(val)
      @_destroy = val
    end
  #ATRIBUTOS

  def adjust_product_stock
    difference = quantity.to_f - quantity_was.to_f
    if difference > 0
      self.product.remove_stock(quantity: difference, depot_id: self.depot_id)
    else
      self.product.add_stock(quantity: -difference, depot_id: self.depot_id)
    end
  end

end
