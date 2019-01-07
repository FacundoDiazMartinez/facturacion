class Client < ApplicationRecord
	has_many :invoices
	has_many :receipts, through: :invoices
	has_many :account_movements
	has_many :client_contacts
	belongs_to :company
	belongs_to :user, optional: true

	default_scope { where(active:true) }

	after_create :set_create_activity, if: :belongs_to_user?

	after_update :set_update_activity

	IVA_COND = ["Responsable Inscripto", "Responsable Monotributo", "Consumidor Final", "Exento"]

	validates_numericality_of :document_number, message: 'Ingrese un numero de documento valido.'
	validates :document_number, length: { is: 11, message: 'Numero de documento inválido, verifique.' }, 		if: Proc.new{|c| ['CUIT', 'CUIL', 'CDI'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates :document_number, length: { maximum: 11, message: 'Numero de documento inválido, verifique.' }, 	if: Proc.new{|c| ['LE', 'LC', 'CI Extranjera', 'Acta Nacimiento', 'Pasaporte'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates :document_number, length: { minimum: 6, message: 'Numero de documento inválido, verifique.' }, 	if: Proc.new{|c| ['en tramite', 'DNI'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates_uniqueness_of :document_number, scope: [:company_id, :document_type], message: 'Ya existe un cliente con ese documento.', if: Proc.new{|c| not c.default_client?}
	validates_presence_of :name, message: "Debe especificar el nombre del cliente."
	validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
	validates_inclusion_of :document_type, in: Afip::DOCUMENTOS.values, message: "Tipo de documento inválido."
	validates_inclusion_of :iva_cond, in: IVA_COND, message: "Condición frente a I.V.A. inválida."
	validates_numericality_of :saldo, message: "Saldo inválido. Revise por favor."
	validates_presence_of :saldo, message: "Saldo inválido. Revise por favor."

	accepts_nested_attributes_for :client_contacts, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :invoices, reject_if: :all_blank, allow_destroy: true


	# TABLA
	# create_table "clients", force: :cascade do |t|
	#     t.string "name", null: false
	#     t.string "phone"
	#     t.string "mobile_phone"
	#     t.string "email"
	#     t.string "address"
	#     t.string "document_type", default: "D.N.I.", null: false
	#     t.string "document_number", null: false
	#     t.string "birthday"
	#     t.boolean "active", default: true, null: false
	#     t.string "iva_cond", default: "Responsable Monotributo", null: false
	#     t.bigint "company_id"
	#     t.bigint "user_id"
	#     t.datetime "created_at", null: false
	#     t.datetime "updated_at", null: false
	#     t.float "saldo", default: 0.0, null: false
	#     t.index ["company_id"], name: "index_clients_on_company_id"
	#     t.index ["user_id"], name: "index_clients_on_user_id"
	#   end
	# TABLA

	#FILTROS DE BUSQUEDA
	def self.find_by_full_document params={}
		where(document_type: params[:document_type], document_number: params[:document_number])
	end

	def self.search_by_name name
		if !name.nil?
  			where("LOWER(name) LIKE LOWER(?)", "%#{name}%")
		else
  			all
		end
	end

    def self.search_by_document document_number
      	if !document_number.blank?
        	where("document_number ILIKE ?", "#{document_number}%")
      	else
        	all
      	end
    end

	#FILTROS DE BUSQUEDA

	#ATRIBUTOS
		def iva_cond_sym
			iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
		end
	#ATRIBUTOS

	#PROCESOS
		def destroy
			update_column(:active,false)
		end

		def set_attributes attrs
			self.attributes = self.attributes.merge(attrs)
		end

		def set_create_activity
			UserActivity.create_for_new_client self
		end

		def set_update_activity
			UserActivity.create_for_updated_client self unless !changed?
		end
	#PROCESOS

	#FUNCIONES

		def belongs_to_user?
			not user_id.nil?
		end

		def self.create_or_update_for_invoice params, invoice
			client = where(document_number: params[:document_number], document_type: params[:document_type]).first_or_initialize
			client.update_attributes(client.attributes.merge(params))
			if client.save
				invoice.update_column(:client_id, client.id)
			end
			return client
		end

		def default_client?
			document_type == "99" && document_number == "0"
		end

		def full_document
			"#{Afip::DOCUMENTOS.key(document_type)}: #{document_number}"
		end

		def birthday
			read_attribute("birthday") || "Sin registrar"
		end
	#FUNCIONES
end
