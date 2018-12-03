class ArrivalNote < ApplicationRecord
  belongs_to :company
  belongs_to :purchase_order
  belongs_to :user

  has_many :arrival_note_details

  accepts_nested_attributes_for :arrival_note_details, reject_if: :all_blank, allow_destroy: true

  before_create :set_number

  before_validation :check_details

  STATES = ["Pendiente", "Anulado", "Finalizado"]


  #FILTROS DE BUSQUEDA
    def self.search_by_purchase_order number
      if not number.blank?
        where("purchase_orders.number = ?", number)
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

  #PROCESOS
    def set_number
      last_an = ArrivalNote.where(company_id: company_id).last
      self.number = last_an.nil? ? 1 : (last_an.number.to_i + 1) 
    end
  #PROCESOS

  #FUNCIONES
    def check_details
      errors.add(:details, "No puede guardar un remito vacio.") unless arrival_note_details.count > 0
    end
  #FUNCIONES
end
