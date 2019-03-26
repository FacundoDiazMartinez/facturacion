class DeliveryNoteDetail < ApplicationRecord
  include Deleteable
  belongs_to :delivery_note, optional: true
  belongs_to :product, optional: true, class_name: "ProductUnscoped"
  belongs_to :depot
  has_many :invoice_details, through: :delivery_note


  validates_presence_of :delivery_note, message:  "El concepto debe tener asociado un remito."
  validates_presence_of :product, message:  "El concepto debe tener asociado un producto."
  validates_presence_of :depot, message:  "El concepto debe tener asociado un depósito."

  after_validation :adjust_product_stock, if: Proc.new{|detail| detail.delivery_note.state == "Finalizado"}

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
    difference = quantity.to_f
    self.product.deliver_product(quantity: difference, depot_id: self.depot_id, from: "Reservado")
  end

end
