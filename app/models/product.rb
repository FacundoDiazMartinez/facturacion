class Product < ApplicationRecord

  	belongs_to :product_category, optional: true
  	belongs_to :company
  	belongs_to :user_who_updates, foreign_key: "updated_by", class_name: "User", optional: true
  	belongs_to :user_who_creates, foreign_key: "created_by", class_name: "User", optional: true
  	belongs_to :supplier, optional: true
  	has_many   :stocks
  	has_many   :depots, through: :stocks
  	has_many   :invoice_details
  	has_many   :invoice, through: :invoice_details
  	has_many   :purchase_order_details
  	has_many   :purchase_orders, through: :purchase_order_details
  	has_many   :arrival_note_details
  	has_many   :arrival_note, through: :arrival_note_details
  	has_many   :product_price_histories

    scope :active, -> { where(active: true) }
    validates_uniqueness_of :code, scope: [:company_id, :active, :tipo], message: "Ya existe un producto con el mismo identificador.", if: :active
    validates_uniqueness_of :name, scope: [:company_id, :active], message: "Ya existe un producto con el mismo nombre.", if: :active
  	validates_presence_of :price, message: "Debe ingresar el precio del producto."
  	validates_presence_of :created_by, message: "Debe ingresar el usuario creador del producto."
  	validates_presence_of :updated_by, message: "Debe ingresar quien actualizó el producto.", if: :persisted?
  	validates_numericality_of :price, message: "El precio solo debe contener caracteres numéricos."
  	validates_presence_of :code, message: "Debe ingresar un código en el producto."
  	validates_presence_of :name, message: "El nombre del producto no puede estar en blanco."
  	validates_presence_of :company_id, message: "El producto debe estar asociado a su compañía."

  	after_save :add_price_history, if: Proc.new{|p| p.saved_change_to_price?}
  	after_create :create_price_history

  	accepts_nested_attributes_for :stocks, reject_if: :all_blank, allow_destroy: true


  	MEASUREMENT_UNITS = {
	  	"1" => "kilogramos",
	  	"2" => "metros",
	  	"3" => "metros cuadrados",
	  	"4" => "metros cúbicos",
	  	"5" => "litros",
	  	"6" => "1000 kWh",
	  	"7" => "unidades",
	  	"8" => "pares",
	  	"9" => "docenas",
	  	"10" => "quilates",
	  	"11" => "millares",
	  	"14" => "gramos",
	  	"15" => "milimetros",
	  	"16" => "mm cúbicos",
	  	"17" => "kilómetros",
	  	"18" => "hectolitros",
	  	"20" => "centímetros",
	  	"25" => "jgo. pqt. mazo naipes",
	  	"27" => "cm cúbicos",
	  	"29" => "toneladas",
	  	"30" => "dam cúbicos",
	  	"31" => "hm cúbicos",
	  	"32" => "km cúbicos",
	  	"33" => "microgramos",
	  	"34" => "nanogramos",
	  	"35" => "picogramos",
	  	"41" => "miligramos",
	  	"47" => "mililitros",
	  	"48" => "curie",
	  	"49" => "milicurie",
	  	"50" => "microcurie",
	  	"51" => "uiacthor",
	  	"52" => "muiacthor",
	  	"53" => "kg base",
	  	"54" => "gruesa",
	  	"61" => "kg bruto",
	  	"62" => "uiactant",
	  	"63" => "muiactant",
	  	"64" => "uiactig",
	  	"65" => "muiactig",
	  	"66" => "kg activo",
	  	"67" => "gramo activo",
	  	"68" => "gramo base",
	  	"96" => "packs",
	  	"98" => "otras unidades"
	}
	validates_inclusion_of :measurement_unit, :in => MEASUREMENT_UNITS.keys, if: Proc.new{|p| not p.measurement_unit.nil?}, allow_blank: true

	#FILTROS DE BUSQUEDA
		def self.search_by_name name
			if not name.blank?
				where("products.name ILIKE ? ", "%#{name}%")
			else
				all
			end
		end

		def self.search_by_code code
			if not code.blank?
				where("products.code ILIKE ? ", "%#{code}%")
			else
				all
			end
		end

		def self.search_by_category category
			if not category.blank?
				joins(:product_category).where("product_categories.id = ? ", category)
			else
				all
			end
		end

		def self.search_by_product_category_id category_id
			unless category_id.blank?
				where(product_category_id: category_id)
			else
				all
			end
		end

		def self.search_by_supplier supplier
			if not supplier.blank?
				joins(product_category: :supplier).where("suppliers.id = ? ", supplier)
			else
				all
			end
		end

		def self.search_by_supplier_id supplier_id
			unless supplier_id.blank?
				where(supplier_id: supplier_id)
			else
				all
			end
		end

		def self.search_with_stock stock
			if stock == "on"
				joins(:stocks).where("stocks.state = 'Disponible'")
			else
				all
			end
		end

		def self.search_by_depot depot_id
			if !depot_id.blank?
				joins(stocks: :depot).where("depots.id = ?", depot_id)
			else
				all
			end
		end
	#FILTROS DE BUSQUEDA

  	#ATRIBUTOS
	  	def full_name
	  		"#{tipo}: #{code} - #{name}"
	  	end

	  	def photo
			read_attribute("photo") || "/images/default_product.jpg"
		end

		def category_name
			product_category.nil? ? "Sin categoría" : product_category.name
		end

		def set_available_stock
			update_column(:available_stock, self.stocks.where(state: "Disponible").sum(:quantity))
		end

		def iva
			Afip::ALIC_IVA.map{|ai| ai.last unless ai.first.to_i != iva_aliquot.to_i}.compact.join().to_f * 100
		end

		def full_measurement
			"#{measurement} #{MEASUREMENT_UNITS[measurement_unit]}"
		end

		def measurement_unit_name
			MEASUREMENT_UNITS[measurement_unit]
		end

		def supplier_name
			supplier_id.nil? ? "Sin proveedor" : supplier.name
		end

		def stock_html
			if !minimum_stock.blank?
				if available_stock <= minimum_stock
					return "<div class='text-danger'>#{available_stock}</div>".html_safe
				else
					return "<div class='text-success'>#{available_stock}</div>".html_safe
				end
			else
				return "<div class='text-success'>#{available_stock}</div>".html_safe
			end
		end
	#ATRIBUTOS

	#ATRIBUTOS VIRTUALES
	def price_modification=(new_price)
    @price_modification = new_price
    if (new_price.to_s.ends_with? "%" )
    	self.price += (self.price * (new_price.to_d/100)).round(2)
    else
    	self.price = new_price
    end
	end
	#ATRIBUTOS VIRTUALES

	#PROCESOS
		def self.create params
			product = Product.where(company_id: company_id, code: code, name: name).first_or_initialize
			if product.new_record?
				super
			else
				update(params)
			end
		end

		def add_price_history
			old_price = saved_changes[:price].first.to_f
			percentage = (price * 100 / old_price).to_f.round(2) - 100
			self.product_price_histories.create(price: price, percentage: percentage, created_by: created_by)
		end

		def create_price_history
			self.product_price_histories.create(price: price, percentage: 0, created_by: created_by)
		end

		def add_stock attrs={}
			s = self.stocks.where(depot_id: attrs[:depot_id], state: "Disponible").first_or_initialize
			s.quantity = s.quantity.to_f + attrs[:quantity].to_f
			s.save
		end

		def remove_stock attrs={}
			s = self.stocks.where(depot_id: attrs[:depot_id], state: "Disponible").first_or_initialize
			s.quantity = s.quantity.to_f - attrs[:quantity].to_f
			s.save
		end

		def deliver_product attrs={}
			s = self.stocks.where(depot_id: attrs[:depot_id], state: attrs[:from]).first_or_initialize
			s.quantity = s.quantity.to_f - attrs[:quantity].to_f
			if s.save
				d = self.stocks.where(depot_id: attrs[:depot_id], state: "Despachado").first_or_initialize
				d.quantity = d.quantity.to_f + attrs[:quantity].to_f
				d.save
			end
		end

		def reserve_stock attrs={}
			s = self.stocks.where(depot_id: attrs[:depot_id], state: "Reservado").first_or_initialize
			s.quantity = s.quantity.to_f + attrs[:quantity].to_f
			if s.save
				remove_stock attrs
			else
				pp s.errors
			end
		end

		def rollback_reserved_stock attrs={}
			s = self.stocks.where(depot_id: attrs[:depot_id], state: "Reservado").first_or_initialize
			s.quantity = s.quantity.to_f - attrs[:quantity].to_f
			s.save
			if s.save
				add_stock attrs
			end
		end

    def rollback_delivered_stock attrs={}
			s = self.stocks.where(depot_id: attrs[:depot_id], state: "Entregado").first_or_initialize
			s.quantity = s.quantity.to_f - attrs[:quantity].to_f
			if s.save
				add_stock attrs
			end
		end

    def destroy
      update_column(:active,false)
    end

    #IMPORTAR EXCEL o CSV
    def self.save_excel file, supplier_id, current_user
    	#TODO Añadir created_by y updated_by
    	spreadsheet = open_spreadsheet(file)
    	excel = []
    	(2..spreadsheet.last_row).each do |r|
    		excel << spreadsheet.row(r)
    	end
    	header = self.permited_params
    	categories = {}
    	current_user.company.product_categories.map{|pc| categories[pc.name] = pc.id}
    	delay.load_products(excel, header, categories, current_user, supplier_id)
    end

		def self.load_products spreadsheet, header, categories, current_user, supplier_id
			products 	= []
    		invalid 	= []
			(0..spreadsheet.size - 1).each do |i|
	    		row = Hash[[header, spreadsheet[i]].transpose]
	    		product = new
	    		if categories["#{row[:product_category_name]}"].nil?
	    			pc = ProductCategory.new(name: row[:product_category_name], company_id: current_user.company_id)
	    			if pc.save
	    				product_category_id = pc.id
	    				categories["#{row[:product_category_name]}"] = product_category_id
	    			end
	    		end
	    		product.supplier_id 		= supplier_id
	    		product.product_category_id = categories["#{row[:product_category_name]}"]
	    		product.code 				= row[:code]
	    		product.supplier_code 		= row[:supplier_code]
	    		product.name 				= row[:name]
	    		product.cost_price 			= row[:cost_price].round(2) unless row[:cost_price].nil?
	    		product.net_price 			= row[:net_price].round(2) unless row[:net_price].nil?
	    		product.price 				= row[:price].round(2) unless row[:price].nil?
	    		product.measurement_unit 	= Product::MEASUREMENT_UNITS.map{|k,v| k unless v != row[:measurement_unit]}.compact.join()
	    		product.iva_aliquot 		= Afip::ALIC_IVA.map{|k,v| k unless (v*100 != row[:iva_aliquot])}.compact.join()
	    		product.company_id 			= current_user.company_id
	    		product.created_by 			= current_user.id
	    		product.updated_by 			= current_user.id
	    		if product.valid?
	    			products << product
	    		else
	    			invalid << [i, product.name, product.errors.full_messages]
	    		end
	    	end
	    	Product.import products unless !invalid.empty?
    		return_process_result(invalid, current_user)
		end

    def self.return_process_result invalid, user
      if invalid.any?
        {
          'result' => false,
          'message' => 'Uno o mas productos no pudieron importarse.',
          'product_with_errors' => invalid
        }
        Notification.create_for_failed_import invalid, user
      else
        {
          'result' => true,
          'message' => 'Todos los productos fueron correctamente importados a la base de datos.',
          'product_with_errors' => []
        }
        Notification.create_for_success_import user
      end
    end

		def self.permited_params
		    [:product_category_name, :code, :name, :supplier_code, :cost_price, :iva_aliquot, :net_price, :price, :measurement, :measurement_unit]
		end

		def self.open_spreadsheet(file)
		    case File.extname(file.original_filename)
		    when ".csv" then Roo::Csv.new(file.path)
		    when ".xls" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
		    when ".xlsx" then Roo::Excelx.new(file.path)
		    else raise "Unknown file type: #{file.original_filename}"
		    end
		end
		#IMPORTAR EXCEL o CSV

	#PROCESOS

	private
		def self.default_scope
		 	where(active: true, tipo: "Producto")
		end
end
