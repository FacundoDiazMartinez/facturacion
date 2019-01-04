class DailyCash < ApplicationRecord
  belongs_to :company
  has_many   :daily_cash_movements

  after_save :create_initial_movement, if: Proc.new{|dc| dc.state != "Cerrada"}
  after_save :close_daily_cash, if: Proc.new{|dc| dc.state == "Cerrada"}
  before_validation :set_initial_state, on: :create
  
  validates_uniqueness_of :date, scope:  :company_id, message: "No se puede abrir dos veces caja en el mismo día."
  validates_presence_of :initial_amount, message: "Debe especificar un valor de inicio."

  STATES = ["Abierta", "Cerrada"]

  PAYMENT_TYPES = {
    "Caja diaria"             => "0",
    "Tarjeta de crédito"      => "1",
    "Tarjeta de débito"       => "2",
    "Transferencia bancaria"  => "3",
    "Cheque"                  => "4",
    "Retenciones"             => "5"
  }

  #ATRIBUTOS
    def current_user=(user)
      @current_user = user 
    end
  #ATRIBUTOS

  #FILTROS DE BUSQUEDA
  	def self.search_by_date date
  		if date.blank?
  			date = Date.today
  		end
      find_by_date(date)
  	end

  	def self.search_by_user user
  		if !user.blank?
  			joins(:daily_cash_movements).where("daily_cash_movements.user_id = ?", user)
  		else
  			all 
  		end
  	end
  #FILTROS DE BUSQUEDA

  #FUNCIONES
  	def self.last_value company_id
  		daily_cashes = where(company_id: company_id)
  		if daily_cashes.empty?
  			0.0
  		else
  			daily_cashes.order("created_at DESC").last.final_amount
  		end
  	end

    def self.current_daily_cash company_id
      daily = Company.find(company_id).daily_cashes.find_by_date(Date.today)
      if daily.nil?
        raise Exceptions::DailyCashClose
      else
        return daily
      end
    end

    def self.open? daily_cash
      if daily_cash.nil?
        return false
      else
        return daily_cash.state == "Abierta"
      end
    end

    def self.all_daily_cash_movements daily_cash
      daily_cash_movements = []
      if not daily_cash.nil?
        daily_cash.daily_cash_movements.each do |dcm|
          daily_cash_movements << dcm 
        end
      end
      return daily_cash_movements
    end
  #FUNCIONES

  #PROCESOS
    def create_initial_movement
      self.daily_cash_movements.create(
        movement_type: "Apertura de caja",
        amount: initial_amount,
        associated_document: "-",
        payment_type: "",
        flow: "income",
        user_id: @current_user
      )
    end

    def update_current_amount
      total = daily_cash_movements.where(flow: "income").sum(:amount) - daily_cash_movements.where(flow: "expense").sum(:amount)
      update_column(:current_amount, total)
    end

    def set_initial_state
      self.state = "Abierta"
    end

    def close_daily_cash
      if current_amount != final_amount
        diferencia = final_amount - current_amount
        return self.daily_cash_movements.create(
          amount: diferencia,
          movement_type: "Ajuste",
          flow: diferencia > 0 ? "income" : "expense",
          observation:  "Ajuste generado automaticamente por el sistema. Al momento de realizarse se observa monto de cierre igual a $#{final_amount}, monto de caja al momento de cierre igual a $#{current_amount}."
        )
      end
    end    
  #PROCESOS
end
