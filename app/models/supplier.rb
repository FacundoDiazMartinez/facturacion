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

  #FILTROS DE BUSQUEDA
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
  #FILSTROS DE BUSQUEDA
end
