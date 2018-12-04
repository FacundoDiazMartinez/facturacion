class Depot < ApplicationRecord
  belongs_to :company
  has_many   :stocks

  validates_presence_of :company_id, message: "El depósito debe estar vinculado a una compañía."
  validates_presence_of :name, message: "El nombre no puede estar en blanco."
  validates_presence_of :stock_count, message: "Debe estar vinculado a un stock actual."
  validates_numericality_of :stock_count, greater_than_or_equal_to: 0.0, message: "El stock actual debe ser mayor o igual a 0."
  validates_presence_of :location, message: "Debe especificar una ubicación para el depósito."

  # TABLA
  # 	create_table "depots", force: :cascade do |t|
	 #    t.string "name"
	 #    t.boolean "active", default: true, null: false
	 #    t.bigint "company_id"
	 #    t.float "stock_count", default: 0.0, null: false
	 #    t.boolean "filled", default: false, null: false
	 #    t.string "location", null: false
	 #    t.datetime "created_at", null: false
	 #    t.datetime "updated_at", null: false
	 #    t.index ["company_id"], name: "index_depots_on_company_id"
	 #  end
  # TABLA


  #FILTROS DE BUSQUEDA
  	def self.search_by_name name
	      	if !name.nil?
	        	where("LOWER(name) LIKE LOWER(?)", "%#{name}%")
	      	else
	        	all 
	      	end
	    end

	    def self.search_by_state state
	      	case state
	      	when "Disponible"
	      		where(filled: false)
	      	when "LLeno"
	      		where(filled: true)
	      	when ""
	      		all
	      	else
	      		all
	      	end
	    end
	#FILTROS DE BUSQUEDA
end
