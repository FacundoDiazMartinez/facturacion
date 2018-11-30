class Supplier < ApplicationRecord
  belongs_to :company
  has_many 	 :purchase_orders
  has_many 	 :purchase_invoices

  after_create :set_create_activity
  after_save   :set_update_activity

  #ATRIBUTOS
  	def full_document
		"#{Afip::DOCUMENTOS.key(document_type)}: #{document_number}"
	end

  def current_user=(var)
    @current_user = var
  end

  def current_user
    @current_user
  end
  #ATRIBUTOS

  #PROCESOS
  	def set_create_activity
  		UserActivity.create_for_new_supplier self, current_user
  	end

  	def set_update_activity
  		UserActivity.create_for_updated_supplier self, current_user
  	end
  #PROCESOS
end
