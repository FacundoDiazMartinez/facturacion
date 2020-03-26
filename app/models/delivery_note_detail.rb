class DeliveryNoteDetail < ApplicationRecord
  include Deleteable
  belongs_to :delivery_note, optional: true
  belongs_to :product, optional: true, class_name: "ProductUnscoped"
  belongs_to :depot
  belongs_to :invoice_detail, optional: true

  has_many :invoice_details, through: :delivery_note

  validates_presence_of :delivery_note, message:  "El concepto debe tener asociado un remito."
  validates_presence_of :product, message:  "El concepto debe tener asociado un producto."
  validates_presence_of :depot, message:  "El concepto debe tener asociado un depósito."

  default_scope { where(active: true ) }

  attr_accessor :available_product_quantity

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

  def self.pendiente_de_entrega(invoice_detail)
    entregado_previamente = self.includes(:delivery_note).where(delivery_notes: { state: "Finalizado", invoice_id: invoice_detail.invoice_id }, product_id: invoice_detail.product_id).pluck(:quantity).inject(0, :+)
    faltante = invoice_detail.quantity - entregado_previamente
    return 0 if faltante < 0
    faltante
  end
end
