class PurchaseOrderDetail < ApplicationRecord
  belongs_to :purchase_order
  belongs_to :product

  before_validation :check_product

  accepts_nested_attributes_for :product, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :product_id, message: "Falta id de producto."
  validates_presence_of :price, message: "Falta precio unitario."
  validates_presence_of :quantity, message: "Falta especificar cantidad."
  validates_presence_of :total, message: "Total no especificado."
  validates_uniqueness_of :product_id, scope: :purchase_order_id, message: "No es posible ingresar productos iguales."

	def check_product
    if self.product.new_record?
      product.company_id  = self.purchase_order.company_id
      product.created_by  = self.purchase_order.user_id
      product.price       = 0.0
      product.iva_aliquot = "03"
      product.updated_by  = self.purchase_order.user_id
      product.save
      unless product.errors.any?
        self.product      = product
        self.price        = product.cost_price
        self.total        = self.price * self.quantity
      end
    else
      product.updated_by  = self.purchase_order.user_id
    end
  end

  def product_attributes=(attributes)
    if !attributes['id'].blank?
      self.product = Product.where(id: attributes['id']).first
      if self.product.nil?
        attributes['id'] = ""
      end
    end
    super
  end

  def associates_arrival_note_details
    purchase_order.arrival_note_details.where('arrival_note_details.product_id = ? ', product_id)
  end

  def left_quantity
    unless self.nil?
      quantity - associates_arrival_note_details.sum(:quantity)
    else
      0
    end
  end
end
