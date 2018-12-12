class Client < ApplicationRecord
	has_many :invoices
	has_many :receipts, through: :invoices
	has_many :account_movements
	belongs_to :company
	belongs_to :user, optional: true

	default_scope { where(active:true) }

	after_create :set_create_activity, if: :belongs_to_user?

	after_update :set_update_activity

	validates_numericality_of :document_number, message: 'Ingrese un numero de documento valido.'
	validates :document_number, length: { is: 11, message: 'Numero de documento inválido, verifique.' }, 		if: Proc.new{|c| ['CUIT', 'CUIL', 'CDI'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates :document_number, length: { maximum: 11, message: 'Numero de documento inválido, verifique.' }, 	if: Proc.new{|c| ['LE', 'LC', 'CI Extranjera', 'Acta Nacimiento', 'Pasaporte'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates :document_number, length: {minimum: 6, message: 'Numero de documento inválido, verifique.' }, 	if: Proc.new{|c| ['en tramite', 'DNI'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates_uniqueness_of :document_number, scope: [:company_id, :document_type], message: 'Ya existe un cliente con ese documento.', if: Proc.new{|c| not c.default_client?}

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
			UserActivity.create_for_updated_client self
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
