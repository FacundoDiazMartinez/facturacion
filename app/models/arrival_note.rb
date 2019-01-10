class ArrivalNote < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :purchase_order, optional: true
  belongs_to :user, optional: true
  belongs_to :depot, optional: true
  has_many :arrival_note_details, dependent: :destroy

  accepts_nested_attributes_for :arrival_note_details, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :purchase_order, reject_if: :all_blank

  before_validation :set_number
  after_save :set_state
  after_save  :remove_stock, if: Proc.new{|an| pp an.saved_change_to_state? && state == "Anulado"}
  after_save :check_purchase_order_state

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

  #ATRIBUTOS
    def purchase_order_attributes=(attributes)
      self.purchase_order_id = attributes["id"]
      super
    end

    def purchase_order_number
      purchase_order.nil? ? "" : purchase_order.number
    end
  #ATRIBUTOS


  #FILTROS DE BUSQUEDA
    def self.search_by_purchase_order number
      if not number.blank?
        where("purchase_orders.number ILIKE ?", "%#{number}%")
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
      self.number = self.number.to_s.rjust(8,padstr= '0')
    end

    def set_state
      if !arrival_note_details.map(&:completed).include?(false)
        update_column(:state, "Finalizado") unless state == "Anulado"
      else
        update_column(:state, "Pendiente") unless state == "Anulado"
      end
    end

    def remove_stock
      arrival_note_details.each do |detail|
        detail.remove_stock
      end
    end


    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end

    def check_purchase_order_state
      if purchase_order.state == "Finalizada"
        purchase_order.close_arrival_notes
      end
    end
  #PROCESOS

  #FUNCIONES
    def editable?
      state == "Pendiente"
    end
  #FUNCIONES
end
