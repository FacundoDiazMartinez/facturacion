class ArrivalNoteDetail < ApplicationRecord
  belongs_to :arrival_note
  belongs_to :product

  after_create      :change_product_stock
  after_validation  :adjust_product_stock, if: Proc.new{|detail| detail.quantity_changed? && detail.arrival_note.state != "Anulado" && !detail.new_record?}
  before_destroy    :remove_stock



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

  #ATRIBUTOS
    def quantity
      (read_attribute("quantity") || self.req_quantity).to_f
    end

    def completed
      self.req_quantity.to_f <= self.quantity.to_f
    end

    def product_name
      product.nil? ? "" : product.name
    end

    def product_code
      product.nil? ? "" : product.code
    end

  #ATRIBUTOS

  #PROCESOS

    def change_product_stock
      self.product.add_stock(quantity: self.quantity, depot_id: self.arrival_note.depot_id)
    end

    def remove_stock
      self.product.remove_stock(quantity: self.quantity, depot_id: self.arrival_note.depot_id)
    end

    def adjust_product_stock
      difference = quantity.to_f - quantity_was.to_f
      if difference > 0
        self.product.add_stock(quantity: difference, depot_id: self.arrival_note.depot_id)
      else
        self.product.remove_stock(quantity: -difference, depot_id: self.arrival_note.depot_id)
      end
    end

  #PROCESOS

  #FUNCION
    def associates_purchase_order_detail purchase_order
      purchase_order.purchase_order_details.find_by_product_id(product_id)
    end
  #FUNCION
end
