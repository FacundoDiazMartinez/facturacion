class DailyCash < ApplicationRecord
  belongs_to :company
  has_many   :daily_cash_movements

  after_save :create_initial_movement, if: Proc.new{|dc| dc.state != "Cerrada"}
  after_save :close_daily_cash, if: Proc.new{|dc| dc.state == "Cerrada"}
  after_touch :check_childrens, if: :persisted?
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
      daily = Company.find(company_id).daily_cashes.where(state: "Abierta").find_by_date(Date.today)
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

    def self.all_daily_cash_movements daily_cash, user, payment_type
      daily_cash_movements = []
      if not daily_cash.nil?
        daily_cash.daily_cash_movements.search_by_user(user).search_by_payment_type(payment_type).order("created_at DESC").each do |dcm|
          daily_cash_movements << dcm
        end
      end
      return daily_cash_movements
    end

    def open_flow
      if initial_amount > 0
        "income"
      elsif initial_amount < 0
        "expense"
      else
        "neutral"
      end
    end
  #FUNCIONES

  #PROCESOS

    def check_childrens
      if daily_cash_movements.count == 0
        self.destroy
      end
    end

    def create_initial_movement
      self.daily_cash_movements.create(
        movement_type: "Apertura de caja",
        amount: initial_amount,
        associated_document: "-",
        payment_type: "0",
        flow: open_flow,
        user_id: @current_user,
        current_balance: initial_amount
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
        self.daily_cash_movements.create(
          amount: diferencia,
          movement_type: "Ajuste",
          associated_document: "-",
          payment_type: "0",
          flow: diferencia > 0 ? "income" : "expense",
          current_balance: final_amount,
          observation:  "Ajuste generado automaticamente por el sistema. Al momento de realizarse se observa monto de cierre igual a $#{final_amount}, monto de caja al momento de cierre igual a $#{current_amount}."
        )
      end
      self.daily_cash_movements.create(
          amount: 0,
          movement_type: "Cierre de caja",
          payment_type: "0",
          flow: "neutral",
          current_balance: self.final_amount,
          observation:  "Cierre de caja. Se registra un monto de cierre de #{self.final_amount} a la fecha.."
        )
    end
  #PROCESOS
end
