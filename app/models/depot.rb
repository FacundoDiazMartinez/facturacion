class Depot < ApplicationRecord
  belongs_to :company
  has_many   :stocks

  validates_presence_of :company_id, message: "El depósito debe estar vinculado a una compañía."
  validates_presence_of :name, message: "El nombre no puede estar en blanco."
  validates_presence_of :stock_count, message: "Debe estar vinculado a un stock actual."
  validates_presence_of :location, message: "Debe especificar una ubicación para el depósito."
  #validates_presence_of :filled, message: "Debe especificar si el depósito se encuentra lleno."

  validates_numericality_of :stock_count, greater_than_or_equal_to: 0.0, message: "El stock actual debe ser mayor o igual a 0."

  default_scope { where(active: true) }


  #FILTROS DE BUSQUEDA
  	def self.search_by_name name
    	if !name.nil?
      	where("LOWER(name) LIKE LOWER(?)", "%#{name}%")
    	else
      	all
    	end
    end

    def self.search_by_availability state
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

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end

    def stock_total
      self.stocks.sum(:quantity)
    end

    def stock_available
      self.stocks.where(state: "Disponible").sum(:quantity)
    end

    def stock_delivered
      self.stocks.where(state: "Entregado").sum(:quantity)
    end

    def stock_reserved
      self.stocks.where(state: "Reservado").sum(:quantity)
    end
#FILTROS DE BUSQUEDA

#FUNCIONES
  def self.check_at_least_one company_id
    raise Exceptions::EmptyDepot if Company.find(company_id).depots.empty?
  end
#FUNCIONES

#PROCESOS
  def change_stock(quantity)
    self.update_column(:stock_count, self.stock_count + quantity)
  end

#PROCESOS
end
