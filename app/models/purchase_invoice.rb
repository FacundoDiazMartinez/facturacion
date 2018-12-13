class PurchaseInvoice < ApplicationRecord
  belongs_to :company
  belongs_to :user
  belongs_to :arrival_note, optional: true
  belongs_to :supplier, optional: true
  belongs_to :purchase_order, optional: true

  has_many   :iva_books

  default_scope{where(active:true)}

  after_create :create_iva_book
  after_create :set_create_activity

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

  # ATRIBUTOS
  def purchase_order_number
    purchase_order.nil? ? "" : purchase_order.number
  end
  # ATRIBUTOS

  #PROCESOS
    def create_iva_book
      IvaBook.add_from_purchase(self)
    end

    def set_create_activity
      UserActivity.create_for_purchase_invoice self
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  #PROCESOS
end
