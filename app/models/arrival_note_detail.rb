class ArrivalNoteDetail < ApplicationRecord
  belongs_to :arrival_note
  belongs_to :product

  before_validation :check_product
  after_create      :change_product_stock

  accepts_nested_attributes_for :product, reject_if: :all_blank

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
  	def check_product
      if new_record?
        product.company_id = arrival_note.company_id
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
  #PROCESOS
end
