class Stock < ApplicationRecord
  belongs_to :product, class_name: "ProductUnscoped"
  belongs_to :depot

  after_save :set_stock_to_category
  after_save :set_stock_to_depot
  after_save :set_stock_to_product

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

  def set_stock_to_category
  	product.product_category.update_column(:products_count, product.available_stock) unless product.product_category.nil?
  end

  def set_stock_to_depot
  	depot.update_column(:stock_count, product.available_stock )
  end

  def set_stock_to_product
    product.set_available_stock
  end

  def product
    Product.unscoped{super}
  end
end