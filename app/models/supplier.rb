class Supplier < ApplicationRecord
  belongs_to :company

  #ATRIBUTOS
  	def full_document
		"#{Afip::DOCUMENTOS.key(document_type)}: #{document_number}"
	end
  #ATRIBUTOS
end
