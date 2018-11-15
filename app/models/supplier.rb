class Supplier < ApplicationRecord
  belongs_to :company
  has_many 	 :purchase_orders
  has_many 	 :purchase_invoices

  #ATRIBUTOS
  	def full_document
		"#{Afip::DOCUMENTOS.key(document_type)}: #{document_number}"
	end
  #ATRIBUTOS
end
