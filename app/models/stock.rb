class Stock < ApplicationRecord
  belongs_to :product, class_name: "ProductUnscoped"
  belongs_to :depot


  after_save :set_stock_to_product
  after_save :set_stock_to_depot

  validate :check_company_of_depot
  validates_uniqueness_of :state, scope: [:product_id, :depot_id], message: "Esta intentando generar estados duplicados para un mismo depósito."

  STATES = ["Disponible", "Reservado", "Entregado"]

  #FILTROS DE BUSQUEDA
    def self.search_by_product name
      if not name.blank?
        joins(:product).where("products.name ILIKE ? ", "%#{name}%")
      else
        all
      end
    end

    def self.search_by_state state
      if not state.blank?
        where(state: state)
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #VALIDACIONES
    def check_company_of_depot
      if not depot_id.blank?
        errors.add(:base, "El depósito no pertenece a su compañía") unless depot.company_id == product.company_id
      end
    end
  #VALIDACIONES

  def set_stock_to_category
  	product.product_category.update_column(:products_count, product.available_stock) unless product.product_category_id.nil?
  end

  def set_stock_to_depot
  	depot.update_column(:stock_count, product.available_stock )
    set_stock_to_category
  end

  def set_stock_to_product
    product.set_available_stock
  end

  def product
    Product.unscoped{super}
  end

  def depot
    Depot.unscoped{super}
  end

end
