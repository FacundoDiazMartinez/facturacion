class Company < ApplicationRecord
	belongs_to :province
	belongs_to :locality

	has_many :sale_points, dependent: :destroy
	has_many :users
	has_many :clients
	has_many :invoices
	has_many :product_categories
	has_many :price_changes
	has_many :products
	has_many :receipts
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
	has_many :income_payments, through: :invoices
	has_many :advertisements
	has_many :sended_advertisements, through: :advertisements
	has_many :payments
	has_many :card_payments, through: :credit_cards
	has_many :bank_payments, through: :banks
	has_many :cheque_payments, through: :payments
	has_many :retention_payments, through: :payments
	has_many :account_movements, through: :clients
	has_many :account_movement_payments, through: :account_movements
	has_many :transfer_requests
	has_many :movements
	has_many :default_tributes

	accepts_nested_attributes_for :sale_points, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :default_tributes, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :banks, allow_destroy: true, reject_if: :all_blank
	accepts_nested_attributes_for :credit_cards, allow_destroy: true, reject_if: :all_blank

	CONCEPTOS = ["Productos", "Servicios", "Productos y Servicios"]

	before_validation :set_code, on: :create
	before_validation :clean_cuit

	validates_presence_of :name, 				message: "Debe ingresar el nombre de su compañía."
	validates_presence_of :society_name, 		message: "Debe ingresar su razón social."
	validates_presence_of :code, 				message: "Error al generar el código de su compañía. Intentelo nuevamente por favor."
	validates_presence_of :moneda, 				message: "Debe seleccionar su moneda principal."
	validates_presence_of :activity_init_date, 	message: "Debe indicar la fecha de inicio de actividad de su compañía."
	validates_presence_of :country, 			message: "Debe seleccionar el país."
	validates_presence_of :province_id, 		message: "Debe seleccionar una provincia."
	validates_presence_of :locality_id, 		message: "Debe seleccionar una localidad."
	validates_presence_of :postal_code, 		message: "Debe ingresar el código postal de la localidad."
	validates_presence_of :address, 			message: "Debe ingresar la dirección de su compañía."
	validates :cuit,
		presence: { message: "El C.U.I.T. no puede estar en blanco." },
		numericality: { only_integer: true, greater_than: 9999999999, less_than: 99999999999, message: "El C.U.I.T. debe contener únicamente números." }
	validates :concepto,
		presence: { message: "Debe seleccionar un concepto." },
		inclusion: { in: ["01","02","03"], message: "El concepto seleccionado es inválido." }
	validates :email,
		presence: { message: "Debe ingresar una dirección de correo electrónico." },
		format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
	validates_length_of :cbu, minimum: 22, maximum: 22, allow_nil: true, message: "C.B.U. inválido. Verifique por favor. Cantidad necesaria de caracteres = 22."

	after_validation :date_less_than_today
	after_save :create_default_deposit, if: :new_record?

	default_scope { where(active: true ) }

	def set_code
		begin
      	self.code = SecureRandom.hex(3).upcase
    end while !Company.select(:code).where(:code => code).empty?
	end

	def clean_cuit
		if self.cuit
			self.cuit = self.cuit.gsub(/\D/, '')
		end
	end

	def date_less_than_today
		errors.add(:activity_init_date, "La fecha de inicio de actividad no puede ser mayor que hoy.") if activity_init_date && activity_init_date > Date.today
	end

	def logo
		super || "/images/default_company.png"
	end

	def concepto_text
		::Afip::CONCEPTOS.map{|k,v| k unless v.to_i != concepto.to_i  }.compact.join()
	end

	def iva_cond_sym
		iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
	end

	def first_sale_point
		raise Exceptions::EmptySalePoint if sale_points.nil?
		return sale_points.first.id
	end

	def last_depot
		raise Exceptions::EmptyDepot if depots.nil?
		return depots.last.id
	end

	def grouped_users_by_role
		roles.map{|r| [r.name, r.users.map{|u| [u.name, u.id]}]}
	end

	def create_default_deposit
		self.depots.create(name: "Central", stock_count: 0, filled: false, location: address)
	end

	def destroy
		update_column(:active, false)
		run_callbacks :destroy
	end
end
