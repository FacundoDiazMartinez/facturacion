class PurchaseInvoice < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :arrival_note, optional: true
  belongs_to :supplier

  has_many   :iva_books

  STATES=["Pendiente", "Falta remito", "Finalizado"]


  #FILTROS DE BUSQUEDA
    def self.search_by_supplier name
      if not name.blank?
        where("suppliers.name ILIKE ?", "%#{name}%")
      else
        all 
      end
    end

    def self.search_by_user name 
      if not name.blank?
        where("LOWER(users.first_name || ' ' || users.last_name) LIKE LOWER(?)", "%#{name}%")
      else
        all 
      end
   end

    def self.search_by_state state 
      if not state.blank?
        where(state: state)
      else
        all 
      end
    end
  #FILTROS DE BUSQUEDA
end
