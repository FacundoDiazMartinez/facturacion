class Product < ApplicationRecord
  	belongs_to :product_category, optional: true
  	belongs_to :company
  	belongs_to :user_who_updates, foreign_key: "updated_by", class_name: "User"
  	belongs_to :user_who_creates, foreign_key: "created_by", class_name: "User"
  	has_many   :stocks
  	has_many   :depots, through: :stocks
  	has_many   :invoice_details
  	has_many   :invoice, through: :invoice_details
  	has_many   :purchase_order_details
  	has_many   :purchase_orders, through: :purchase_order_details
  	has_many   :arrival_note_details
  	has_many   :arrival_note, through: :arrival_note_details
  	has_many   :product_price_histories

    default_scope { where(active: true) }
    scope :active, -> { where(active: true) }

  	validates_presence_of :price, message: "Debe ingresar el precio del producto."
  	validates_presence_of :created_by, message: "Debe ingresar el usuario creador del producto."
  	validates_presence_of :updated_by, message: "Debe ingresar quien actualizó el producto.", if: :persisted?
  	validates_numericality_of :price, message: "El precio solo debe contener caracteres numéricos."
  	validates_presence_of :code, message: "Debe ingresar un código en el producto."
  	validates_presence_of :name, message: "El nombre del producto no puede estar en blanco."
  	validates_uniqueness_of :name, scope: [:company_id, :active], message: "Ya existe un producto con el mismo nombre."
  	validates_presence_of :company_id, message: "El producto debe estar asociado a su compañía."

  	after_save :add_price_history, if: Proc.new{|p| p.saved_change_to_price?}
  	after_create :create_price_history
  	

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
				joins(:product_category).where("product_categories.name ILIKE ? ", "%#{category}%")
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
	#FILTROS DE BUSQUEDA

  	#ATRIBUTOS
	  	def full_name
	  		"#{code} - #{name}"
	  	end

	  	def photo
			read_attribute("photo") || "/images/default_product.jpg"
		end

		def category_name
			product_category.nil? ? "Sin categoría" : product_category.name
		end

		def available_stock
			stocks.where(state: "Disponible").count
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
	#ATRIBUTOS

	#PROCESOS
		def self.create params
			product = Product.where(company_id: company_id, code: code, name: name).first_or_initialize
			if produc.new_record?
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

	    def destroy
	      update_column(:active,false)
	    end

	    #IMPORTAR EXCEL o CSV
	    def self.save_excel file, current_user
	    	#TODO Añadir created_by y updated_by
	      	spreadsheet = open_spreadsheet(file)
        	header = self.permited_params
        	categories = current_user.company.product_categories.map{|pc| {pc.name => pc.id}}.first || {} 
        	load_products(spreadsheet, header, categories, current_user)
		end

		def self.load_products spreadsheet, header, categories, current_user
			products 	= []
	    	invalid 	= []
			(2..spreadsheet.last_row).each do |i|
          		row = Hash[[header, spreadsheet.row(i)].transpose]
          		product = new
          		if not categories["#{row[:product_category_name]}"].nil?
          		 	product.product_category.build(name: row[:product_category_name], company_id: current_user.company_id)
          		else
          		 	product.product_category_id = categories["#{row[:product_category_name]}"]
          		end
          		product.attributes 			= row.reject{|e| e == :product_category_name}.to_hash
          		product.measurement_unit 	= Product::MEASUREMENT_UNITS.map{|k,v| k unless v != row[:measurement_unit]}.compact.join()
          		product.iva_aliquot 		= Afip::ALIC_IVA.map{|k,v| k unless (v*100 != row[:iva_aliquot])}.compact.join()
          		product.company_id 			= current_user.company_id
          		product.created_by 			= current_user.id
          		product.updated_by 			= current_user.id
          		if product.valid?
          			product.save!
          		else
          			pp product.errors
          			invalid << i
          		end
        	end
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
		    [:product_category_name, :code, :name, :cost_price, :iva_aliquot, :net_price, :price, :measurement, :measurement_unit]
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
end
