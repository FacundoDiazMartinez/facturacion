class Company < ApplicationRecord
	has_many :sale_points, dependent: :destroy
	has_many :users
	has_many :clients
	has_many :invoices
	has_many :product_categories
	has_many :products
	has_many :receipts, through: :invoices
	has_many :depots
	has_many :suppliers

	belongs_to :province
	belongs_to :locality

	before_validation :set_code, on: :create
	before_validation :clean_cuit

	validates_presence_of :name, message: "Debe especificar el nombre de su compañía."
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

	accepts_nested_attributes_for :sale_points, allow_destroy: true, reject_if: :all_blank

	CONCEPTOS = ["Productos", "Servicios", "Productos y Servicios"]

	#Inicio Validaciones
		def set_code
			begin
		      	self.code = SecureRandom.hex(3).upcase
		    end while !Company.select(:code).where(:code => code).empty?
		end

		def clean_cuit
			self.cuit = self.cuit.gsub(/\D/, '')
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
end
