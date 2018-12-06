class ArrivalNote < ApplicationRecord
  belongs_to :company
  belongs_to :purchase_order
  belongs_to :user
  belongs_to :depot
  has_many :arrival_note_details
  accepts_nested_attributes_for :arrival_note_details, reject_if: :all_blank, allow_destroy: true
 
  before_validation :check_details, :set_number

  STATES = ["Pendiente", "Anulado", "Finalizado"]

  validates_presence_of :company_id, message: "Debe pertenecer a una compañía."
  validates_presence_of :purchase_order_id, message: "Debe pertenecer a una orden de compra."
  validates_presence_of :user_id, message: "El remito debe estar vinculado a un usuario."
  validates_presence_of :depot_id, message: "El remito debe estar vinculado a un depósito."
  validates_presence_of :number, message: "No puede exitir un remito sin numeración."
  validates_presence_of :state, message: "El remito debe poseer un estado."
  validates_inclusion_of :state, in: STATES, message: "El estado es inválido."

  #TABLA
    # create_table "arrival_notes", force: :cascade do |t|
    #   t.bigint "company_id"
    #   t.bigint "purchase_order_id"
    #   t.bigint "user_id"
    #   t.bigint "depot_id"
    #   t.string "number", null: false
    #   t.boolean "active", default: true, null: false
    #   t.string "state", default: "Pendiente", null: false
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.index ["company_id"], name: "index_arrival_notes_on_company_id"
    #   t.index ["depot_id"], name: "index_arrival_notes_on_depot_id"
    #   t.index ["purchase_order_id"], name: "index_arrival_notes_on_purchase_order_id"
    #   t.index ["user_id"], name: "index_arrival_notes_on_user_id"
    # end
  #TABLA


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
      self.number = self.number.to_s.rjust(6,padstr= '0') 
    end
  #PROCESOS

  #FUNCIONES
    def check_details
      errors.add(:details, "No puede guardar un remito vacio.") unless arrival_note_details.count > 0
    end
  #FUNCIONES
end
