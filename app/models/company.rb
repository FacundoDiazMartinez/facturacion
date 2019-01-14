class Company < ApplicationRecord
	has_many :sale_points, dependent: :destroy
	has_many :users
	has_many :clients
	has_many :invoices
	has_many :product_categories
	has_many :price_changes
	has_many :products
	has_many :receipts, through: :invoices
	has_many :depots
	has_many :suppliers
	has_many :purchase_orders
	has_many :purchase_invoices
	has_many :arrival_notes
	has_many :iva_books
	has_many :roles
	has_many :services
	has_many :user_activities, through: :users
	has_many :daily_cashes
	has_many :daily_cash_movements, through: :daily_cashes
	has_many :banks
	has_many :credit_cards
	has_many :budgets
	has_many :delivery_notes
	has_many :sales_files

	belongs_to :province
	belongs_to :locality

	before_validation :set_code, on: :create
	before_validation :clean_cuit

	after_save :create_default_deposit, if: :new_record?

	CONCEPTOS = ["Productos", "Servicios", "Productos y Servicios"]

	validates_presence_of :name, message: "Debe especificar el nombre de su compañía."
	validates_presence_of :code, message: "No se pudo generar el código de su compañía. Intentelo nuevamente por favor.."
	validates_presence_of :society_name, message: "Debe especificar su razón social."
	validates_presence_of :email, message: "El e-mail no puede estar en blanco."
	validates_presence_of :cuit, message: "El C.U.I.T. no puede estar en blanco."
	validates_presence_of :concepto, message: "Debe elegir un concepto."
	validates_presence_of :moneda, message: "Debe elegir su moneda principal."
	validates_presence_of :activity_init_date, message: "Debe indicar la fecha de inicio de actividad de su compañía."
	validates_presence_of :country, message: "No selecciono un país."
	validates_presence_of :province_id, message: "No selecciono una ciudad."
	validates_presence_of :locality_id, message: "No selecciono una localidad."
	validates_presence_of :postal_code, message: "Debe especificar el código postal."
	validates_presence_of :address, message: "Debe especificar su dirección."
	validates_numericality_of :cuit, message: "El C.U.I.T. debe contener únicamente números."
	validate :date_less_than_today
	validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
	validates_length_of :cbu, minimum: 22, maximum: 22, allow_blank: true, message: "C.B.U. inválido. Verifique por favor. Cantidad necesaria de caracteres = 22."
	validates_length_of :cuit, minimum: 11, maximum: 11, allow_blank: true, message: "C.U.I.T. inválido. Verifique por favor. Cantidad necesaria de caracteres = 11."
	validates_inclusion_of :concepto, in: ::Afip::CONCEPTOS.values, message: "Concepto inválido."


	accepts_nested_attributes_for :sale_points, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :banks, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :credit_cards, allow_destroy: true, reject_if: :all_blank

	# TABLA
	# 	create_table "companies", force: :cascade do |t|
	# 	    t.string "email", null: false
	# 	    t.string "code", null: false
	# 	    t.string "name", null: false
	# 	    t.string "logo"
	# 	    t.string "address"
	# 	    t.string "society_name"
	# 	    t.string "cuit", null: false
	# 	    t.string "concepto", null: false
	# 	    t.string "moneda", default: "PES", null: false
	# 	    t.string "iva_cond", null: false
	# 	    t.string "country", default: "Argentina", null: false
	# 	    t.string "postal_code"
	# 	    t.date "activity_init_date"
	# 	    t.string "contact_number"
	# 	    t.string "environment", default: "testing", null: false
	# 	    t.string "cbu"
	# 	    t.boolean "paid", default: false, null: false
	# 	    t.string "suscription_type"
	# 	    t.datetime "created_at", null: false
	# 	    t.datetime "updated_at", null: false
	# 	    t.bigint "province_id", null: false
	# 	    t.bigint "locality_id", null: false
	# 	    t.index ["locality_id"], name: "index_companies_on_locality_id"
	# 	    t.index ["province_id"], name: "index_companies_on_province_id"
	# 	end
	# TABLA


	#Inicio Validaciones
		def set_code
			begin
		      	self.code = SecureRandom.hex(3).upcase
		    end while !Company.select(:code).where(:code => code).empty?
		end

		def clean_cuit
			self.cuit = self.cuit.gsub(/\D/, '')
		end

		def date_less_than_today
			errors.add(:activity_init_date, "La fecha de inicio de actividad no puede ser mayor que hoy.") unless activity_init_date <= Date.today
		end

		def set_admin_role user_id
			if self.roles.blank?
				admin_role = Role.where(company_id: self.id, name: "Administrador").first_or_create
				UserRole.where(role_id: admin_role.id, user_id: user_id).first_or_create
			end
		end
	#Fin validaciones


	#Inicio atributos
		def logo
			read_attribute("logo") || "/images/default_company.png"
		end

		def concepto_text
			::Afip::CONCEPTOS.map{|k,v| k unless v.to_i != concepto.to_i  }.compact.join()
		end

		def iva_cond_sym
			iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
		end
	#Fin atributos

	#FUNCIONES
		def grouped_users_by_role
			roles.map{|r| [r.name, r.users.map{|u| [u.name, u.id]}]}
		end
	#FUNCIONES

	#PROCESOS
		def create_default_deposit
			self.depots.create(name: "Central", stock_count: 0, filled: false, location: address)
		end
	#PROCESOS
end
