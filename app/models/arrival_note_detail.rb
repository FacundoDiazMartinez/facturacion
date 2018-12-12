class ArrivalNoteDetail < ApplicationRecord
  belongs_to :arrival_note
  belongs_to :product

  before_validation :check_product
  after_create      :change_product_stock

  accepts_nested_attributes_for :product, reject_if: :all_blank

  #validates_presence_of     :arrival_note_id, message: "El detalle debe estar vinculado a un remito."
  validates_presence_of     :product_id, message: "El detalle debe estar vinculado a un producto."
  validates_presence_of     :quantity, message: "El detalle debe poseer una cantidad."
  validates_numericality_of :quantity, greater_than: 0.0, message: "El detalle posee una cantidad inválida. Debe ser mayor a 0."



  # TABLA
    # create_table "arrival_note_details", force: :cascade do |t|
    #   t.bigint "arrival_note_id"
    #   t.bigint "product_id"
    #   t.string "quantity"
    #   t.boolean "cumpliment"
    #   t.string "observation"
    #   t.datetime "created_at", null: false
    #   t.datetime "updated_at", null: false
    #   t.index ["arrival_note_id"], name: "index_arrival_note_details_on_arrival_note_id"
    #   t.index ["product_id"], name: "index_arrival_note_details_on_product_id"
    # end
  # TABLA

  #PROCESOS
  	def check_product #Se ejecuta en caso de que el producto se este creando por medio del remito
      if new_record?
        product.company_id = arrival_note.company_id
        product.created_by = arrival_note.user_id
        product.updated_by = arrival_note.user_id
        product.save
      end
    end

  	def product_attributes=(attributes)
      if !attributes['id'].blank?
        self.product = Product.find(attributes['id'])
      end
      super
    end

    def change_product_stock
      self.product.add_stock(quantity: self.quantity, depot_id: self.arrival_note.depot_id)
    end

    def remove_stock
      self.product.remove_stock(quantity: self.quantity, depot_id: self.arrival_note.depot_id)
    end
  #PROCESOS
end
