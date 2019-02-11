class ProductCategory < ApplicationRecord
  belongs_to :company
  belongs_to :supplier, optional: true
  has_many 	 :products
  has_many   :price_changes

  default_scope { where(active: true) }

  validates_uniqueness_of :name, scope: :company_id, message: "Ya existe una categoria con ese nombre."


  #FILTROS DE BUSQUEDA
	def self.search_by_name name
		if name
			where("product_categories.name ILIKE (?)", "%#{name}%")
		else
			all
		end
	end

	def self.search_by_supplier supplier
  	if not supplier.blank?
  		joins(:supplier).where("suppliers.id = ? ", supplier)
  	else
  		all
  	end
	end
  #FILTROS DE BUSQUEDA

  #ATRIBUTOS
  def iva
    Afip::ALIC_IVA.map{|ai| ai.last unless ai.first != iva_aliquot.to_s}.compact.join().to_f
  end

  def supplier_name
    supplier.nil? ? "Sin proveedor" : supplier.name
  end
  #ATRIBUTOS

  #PROCESOS
  def destroy
    update_column(:active, false)
    run_callbacks :destroy
    freeze
  end

  def change_products_count(quantity)
    update_column(:products_count, self.products_count.to_f + quantity.to_f)
  end
  #PREOCEOS
end
