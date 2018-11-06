class PurchaseOrder < ApplicationRecord
  belongs_to :supplier
  belongs_to :user
  belongs_to :company

  has_many :payments
  has_many :purchase_order_details

  has_one :product

  accepts_nested_attributes_for :payments, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :purchase_order_details, reject_if: :all_blank, allow_destroy: true

  STATES = ["Pendiente de aprobación", "Aprobado", "Concretado", "Pagado", "Anulado", "Finalizado"]

  #ATRIBUTOS
  	def total_left
  		(total - total_pay).round(2)
  	end

  	def supplier_email
  		supplier.nil? ? "-" : supplier.email
  	end

  	def supplier_phone
  		supplier.nil? ? "-" : supplier.phone
  	end

    def details
      purchase_order_details
    end
  #ATRIBUTOS

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
