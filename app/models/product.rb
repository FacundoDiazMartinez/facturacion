class Product < ApplicationRecord
	belongs_to :product_category, optional: true
	belongs_to :company
	belongs_to :user_who_creates, class_name: "User", foreign_key: "created_by", optional: true
  belongs_to :user_who_updates, class_name: "User", foreign_key: "updated_by", optional: true
	belongs_to :supplier, optional: true
	belongs_to :parent, class_name: "Product", foreign_key: "product_id", optional: true

	has_many   :childs, ->(product) { where product_id: product.id }, class_name: "Product"
	has_many   :stocks, dependent: :destroy
	has_many   :depots, through: :stocks
	has_many   :invoice_details
	has_many   :invoice, through: :invoice_details
	has_many   :purchase_order_details
	has_many   :purchase_orders, through: :purchase_order_details
	has_many   :arrival_note_details
	has_many   :arrival_note, through: :arrival_note_details
	has_many   :product_price_histories, dependent: :destroy

  MEASUREMENT_UNITS = {
  	"1" => "kilogramos",
  	"2" => "metros",
  	"3" => "metros cuadrados",
  	"4" => "metros cúbicos",
  	"5" => "litros",
  	"6" => "1000 kWh",
  	"7" => "unidad",
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
  	"98" => "otras unidades",
	}

  validates :code,
    presence: { message: "Debe ingresar un código en el producto." },
    uniqueness: { scope: [:company_id, :active, :tipo], message: "Ya existe un producto con el mismo identificador." }
  validates_uniqueness_of :name,
    presence: { message: "El nombre del producto no puede estar en blanco." },
    uniqueness: { scope: [:company_id, :active], message: "Ya existe un producto con el mismo nombre." }
	validates_presence_of :price,
    presence: { message: "Debe ingresar el precio del producto." },
    numericality: { greater_than: 0, message: "El precio debe ser mayor a 0." }
  validates :cost_price,
    presence: { message: "Debe ingresar el precio de costo del producto." }
	validates_presence_of :created_by, :updated_by, :company_id
	validates_presence_of :iva_aliquot, message: "Ingrese un valor para el IVA."
  validates_inclusion_of :measurement_unit, :in => MEASUREMENT_UNITS.keys, if: Proc.new{|p| not p.measurement_unit.nil?}, allow_blank: true
  validate :validate_unique_state

  before_save :check_net_price, :check_category_products_count
	after_save :add_price_history, if: Proc.new{|p| p.saved_change_to_price?}
	after_create :create_price_history
  after_create :user_activity_for_create, if: Proc.new{ |p| p.name != "Intereses tarjeta de crédito" }

	accepts_nested_attributes_for :stocks, reject_if: :all_blank, allow_destroy: true

  scope :active, -> { where(active: true) }

  def validate_unique_state
    validate_uniqueness_of_in_memory(stocks, [:active, :state, :depot_id], 'Está intentando generar estados duplicados para un mismo depósito.')
  end

  def check_net_price
		if net_price.to_f == 0.0
			self.net_price = (price.to_f / (1 + simple_iva_aliquot.to_f)).round(2)
		end
	end

	#este metodo chequea que los available stock esten todos concordando, pero no se esta ejecutando en ningun lado, lo corro en consola por ahora
	def check_available_stock
		available = 0
		available += stocks.where(state: "Disponible").map(&:quantity).inject(0) { |suma, quantity| suma + quantity }
		unless available_stock == available
			update_column(:available_stock, available)
		end
	end

	def parent_code
		parent.nil? ? "" : parent.code
	end

	def simple_iva_aliquot
		Afip::ALIC_IVA.map{|k,v| v unless k != iva_aliquot}.compact.join().to_f
	end

	def full_name
		"#{tipo}: #{code} - #{name}"
	end

  def measurement_unit
    read_attribute("measurement_unit").blank? ? "7" : read_attribute("measurement_unit")
  end

	def photo
  	read_attribute("photo") || "/images/default_product.jpg"
	end

	def category_name
		product_category.nil? ? "Sin categoría" : product_category.name
	end

	def set_available_stock
		update_column(:available_stock, self.stocks.where(state: "Disponible").sum(:quantity))
    unless self.minimum_stock.nil?
      if self.available_stock <= self.minimum_stock
        unless self.notification_sended?
          UserActivityManager::MinimumStockGenerator.call(self)
          NotificationManager::LowStockNotifier.call(self)
          self.update_column(:notification_sended, true) #se marca el envío de notificación para que no se vuelva a generar si se sigue operando con el producto
        end
      else
        self.update_column(:notification_sended, false) #Reseteo de notificacion cuando ingresó el stock necesario
      end
    end
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
	def check_category_products_count
		if product_category_id_changed?
			ProductCategory.find(product_category_id_change.first).change_products_count(-1) unless product_category_id_change.first.nil? #Actualiza la vieja categoría
			self.product_category.change_products_count(1) #Actualiza la nueva categoria
		end
	end

	def user_activity_for_create
		UserActivity.create_new_product(self)
	end

	def self.create params
		product = Product.where(company_id: company_id, code: code, name: name).first_or_initialize
		if product.new_record?
			super
		else
			update(params)
		end
	end

	def add_price_history
    if saved_changes[:net_price].nil?
        old_price = 0.0
    else
	      old_price = saved_changes[:net_price].first.to_f
    end
		percentage = (net_price * 100 / old_price).to_f.round(2) - 100
		self.product_price_histories.create(price: net_price, percentage: percentage, created_by: created_by)
	end

	def create_price_history
		self.product_price_histories.create(price: net_price, percentage: 0, created_by: created_by)
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
    self.set_available_stock
	end

	def deliver_product attrs={}
		s = self.stocks.where(depot_id: attrs[:depot_id], state: attrs[:from]).first_or_initialize
		s.quantity = s.quantity.to_f - attrs[:quantity].to_f
		if s.save
			d = self.stocks.where(depot_id: attrs[:depot_id], state: "Entregado").first_or_initialize
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
			s.errors
		end
	end

  def impact_stock_by_cred_note(attrs = {})
    if attrs[:associated_invoice]
      comprobante = Invoice.where(id: attrs[:associated_invoice]).first
      reserved_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Reservado").first_or_initialize
  		delivered_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Entregado").first_or_initialize
  		available_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Disponible").first_or_initialize
  		if reserved_stock.new_record?
  			reserved_stock.quantity = 0
  		end
  		if delivered_stock.new_record?
  			delivered_stock.quantity = 0
  		end
  		if available_stock.new_record?
  			available_stock.quantity = 0
  		end
      if comprobante
      	delivered_stock_saved = 0
      	#En este bloque seteamos cantidad reservada y entregada para el producto en cuestion
        reserved_stock_saved = comprobante.invoice_details.where(product_id: self.id)

        comprobante.delivery_notes.where(state: "Finalizado").each do |dn|
      		delivered_stock_saved += dn.delivery_note_details.where(product_id: self.id).map(&:quantity).inject(0) { |suma, quantity| suma + quantity }
    		end
    		#Fin del bloque

        if (attrs[:quantity].to_f > delivered_stock_saved) #Si la NC es mayor que la cantidad entregada en los remitos
        	delivered_stock.quantity 	-=	delivered_stock_saved
        	reserved_stock.quantity		-=	(attrs[:quantity].to_f - delivered_stock_saved)
        	available_stock.quantity 	+=	attrs[:quantity].to_f
        else #Si la NC es menor igual que la cantidad entrega en los remitos
        	# Saca el total de la cantidad entregada, y lo pasa a disponible
        	delivered_stock.quantity  -=	attrs[:quantity].to_f
        	available_stock.quantity 	+=	attrs[:quantity].to_f
        end
        delivered_stock.save
        available_stock.save
        reserved_stock.save
      end
    end
  end

	def rollback_reserved_stock attrs={}
		s = self.stocks.where(depot_id: attrs[:depot_id], state: "Reservado").first_or_initialize
		s.quantity -= attrs[:quantity].to_f
		s.save
		if s.save
			add_stock attrs
		end
	end

  def impact_stock_from_delivery_note_detail attrs={}
    reserved_stock = self.stocks.where(depot_id: attrs[:id_depot_id], state: "Reservado").first_or_initialize
    if reserved_stock.quantity.blank? || reserved_stock.quantity < attrs[:quantity].to_f
      if reserved_stock.quantity > 0
        remaining_quantity = attrs[:quantity].to_f - reserved_stock.quantity
        available_stock = self.stocks.where(depot_id: attrs[:dn_depot_id], state: "Disponible").first_or_initialize
        available_stock.quantity -= remaining_quantity
        available_stock.save
      end
      reserved_stock.quantity = 0
    else
      reserved_stock.quantity -= attrs[:quantity].to_f
    end

    if reserved_stock.save
      delivered_stock = self.stocks.where(depot_id: attrs[:dn_depot_id], state: "Entregado").first_or_initialize
      if delivered_stock.quantity.blank?
        delivered_stock.quantity = attrs[:quantity].to_f
      else
        delivered_stock.quantity += attrs[:quantity].to_f
      end
      delivered_stock.save
    end
  end

  def destroy
  	update_columns(active: false)
  	run_callbacks :destroy
  	freeze
  end

  def rollback_stock_from_delivered_to_reserved attrs={}
  	#Se buscan los depositos con stock entregado y reservado
		delivered_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Entregado").first_or_initialize
		reserved_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Reservado").first_or_initialize

		#Se resta la cantidad de productos al deposito Entregado, y se suman al depósito Reservado
		delivered_stock.quantity = delivered_stock.quantity.to_f - attrs[:quantity].to_f
		reserved_stock.quantity = reserved_stock.quantity.to_f + attrs[:quantity].to_f

		delivered_stock.save
		reserved_stock.save
	end

	def rollback_stock_from_delivered_to_available attrs={}
  	#Se buscan los depositos con stock entregado y reservado
		delivered_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Entregado").first_or_initialize
		available_stock = self.stocks.where(depot_id: attrs[:depot_id], state: "Disponible").first_or_initialize

		#Se resta la cantidad de productos al deposito Entregado, y se suman al depósito Reservado
		delivered_stock.quantity = delivered_stock.quantity.to_f - attrs[:quantity].to_f
		available_stock.quantity = available_stock.quantity.to_f + attrs[:quantity].to_f

		delivered_stock.save
		available_stock.save
	end

  def self.save_excel file, supplier_id, current_user, depot_id, type_of_movement
  	spreadsheet = open_spreadsheet(file)
  	excel = []
  	(2..spreadsheet.last_row).each do |r|
  		excel << spreadsheet.row(r)
  	end
  	header = self.permited_params
  	categories = {}
  	current_user.company.product_categories.map{|pc| categories[pc.name] = pc.id}
  	delay.load_products(excel, header, categories, current_user, supplier_id, depot_id, type_of_movement)
  end

	def self.load_products spreadsheet, header, categories, current_user, supplier_id, depot_id, type_of_movement
		products 	= []
  	invalid 	= []
		(0..spreadsheet.size - 1).each do |i|
  		row = Hash[[header, spreadsheet[i]].transpose]
  		product = where(code: row[:code], company_id: current_user.company_id ).first_or_initialize
  		if categories["#{row[:product_category_name]}"].nil?
  			pc = ProductCategory.new(name: row[:product_category_name], company_id: current_user.company_id)
  			if pc.save
  				product_category_id = pc.id
  				categories["#{row[:product_category_name]}"] = product_category_id
  			end
  		end
  		product.supplier_id 		  = supplier_id
  		product.product_category_id = categories["#{row[:product_category_name]}"]
  		product.code 				      = row[:code]
  		product.supplier_code 		= row[:supplier_code]
  		product.name 				      = row[:name]
  		product.cost_price 			  = row[:cost_price].round(2) unless row[:cost_price].nil?
  		product.net_price 			  = row[:net_price].round(2) unless row[:net_price].nil?
  		product.price 				    = row[:price].round(2) unless row[:price].nil?
  		product.measurement_unit 	= Product::MEASUREMENT_UNITS.map{|k,v| k unless v != row[:measurement_unit]}.compact.join()
  		product.iva_aliquot 		  = Afip::ALIC_IVA.map{|k,v| k unless (v*100 != row[:iva_aliquot])}.compact.join()
  		product.company_id 			  = current_user.company_id
  		product.created_by 			  = current_user.id
  		product.updated_by 			  = current_user.id
  		if !product.save
  			invalid << [i, product.errors.messages.values]
  		else
  			if !depot_id.blank?
    			stock = product.stocks.where(depot_id: depot_id, state: "Disponible").first_or_initialize
          if type_of_movement == "0"
            stock.quantity = row[:stock]
          else
            stock.quantity += row[:stock]
          end
    			stock.save
    		end
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
	  [:product_category_name, :code, :name, :supplier_code, :cost_price, :iva_aliquot, :net_price, :price, :measurement, :measurement_unit, :stock]
	end

	def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
	    when ".csv" then Roo::Csv.new(file.path)
	    when ".xls" then Roo::Spreadsheet.open(file.path, extension: :xlsx)
	    when ".xlsx" then Roo::Excelx.new(file.path)
	    else raise "Tipo de archivo desconocido: #{file.original_filename}"
    end
	end

	private

	def self.default_scope
	 	where(active: true, tipo: "Producto")
	end

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
end
