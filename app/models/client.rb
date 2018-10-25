class Client < ApplicationRecord
	has_many :invoices
	belongs_to :company

	validates_numericality_of :document_number, message: 'Ingrese un numero de documento valido.'
	validates :document_number, length: { is: 11, message: 'Numero de documento inválido, verifique.' }, 		if: Proc.new{|c| ['CUIT', 'CUIL', 'CDI'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates :document_number, length: { maximum: 11, message: 'Numero de documento inválido, verifique.' }, 	if: Proc.new{|c| ['LE', 'LC', 'CI Extranjera', 'Acta Nacimiento', 'Pasaporte'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates :document_number, length: {minimum: 6, message: 'Numero de documento inválido, verifique.' }, 	if: Proc.new{|c| ['en tramite', 'DNI'].include?(Afip::DOCUMENTOS.key(c.document_type))}
	validates_uniqueness_of :document_number, scope: [:company_id, :document_type], message: 'Ya existe un cliente con ese documento.'


	#ATRIBUTOS
		def iva_cond_sym
			iva_cond.parameterize.underscore.gsub(" ", "_").to_sym
		end
	#ATRIBUTOS

	#PROCESOS
		def self.create_or_update_for_invoice params, invoice
			client = where(document_number: params[:document_number], document_type: params[:document_type]).first_or_initialize
			client.update_attributes(client.attributes.merge(params))
			if client.save
				invoice.update_column(:client_id, client.id)
			end
			return client
		end
	#PROCESOS
end
