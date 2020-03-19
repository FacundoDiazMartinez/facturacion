class Stock < ApplicationRecord
  belongs_to :product, class_name: "ProductUnscoped"
  belongs_to :depot

  STATES = ["Disponible", "Reservado"]

  validate :check_company_of_depot
  validates_uniqueness_of :state, scope: [:active, :product_id, :depot_id], message: "No puede generar dos estados iguales para un mismo depósito."

  after_save :set_stock_to_product, :set_stock_to_depot
  after_destroy :reduce_stock_in_depot

  default_scope { where(active: true) }
  scope :disponibles, ->{ where(state: "Disponible") }
  scope :reservados, ->{ where(state: "Reservado") }

  def self.search_by_product name
    return all if name.blank?
    joins(:product).where("products.name ILIKE ? ", "%#{name}%")
  end

  def self.search_by_state state
    return all if state.blank?
    where(state: state)
  end

  def reduce_stock_in_depot
    self.depot.change_stock(-self.quantity)
    self.product.set_available_stock if disponible?
  end

  def destroy
    update_column(:active, false)
    run_callbacks :destroy
  end

  def disponible?
    state == "Disponible"
  end

  def product
    Product.unscoped{super}
  end

  def depot
    Depot.unscoped{super}
  end

  def depot_name
    depot_id.blank? ? "-" : depot.name
  end

  private

  def check_company_of_depot
    unless depot_id.blank?
      errors.add(:base, "El depósito no pertenece a su compañía") unless depot.company_id == product.company_id
    end
  end

  def set_stock_to_category
  	product.product_category.update_column(:products_count, product.available_stock) unless product.product_category_id.nil?
  end

  def set_stock_to_depot
    if not depot.nil?
  	  depot.update_column(:stock_count, product.available_stock )
    end
    set_stock_to_category
  end

  def set_stock_to_product
    product.set_available_stock
  end
end
