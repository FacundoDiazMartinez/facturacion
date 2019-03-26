class DailyCashMovement < ApplicationRecord
  belongs_to :daily_cash, touch: true
  belongs_to :user, optional: true
  belongs_to :payment, optional: true

  after_initialize :set_daily_cash
  after_save :touch_daily_cash_current_amount
  before_save :fix_balance_on_update, if: Proc.new{|dcm|  !dcm.new_record?}
  before_destroy :fix_balance_on_destroy
  after_destroy { |movement| movement.touch_daily_cash_current_amount }
  before_validation :set_payment_type


  TYPES = ["Pago", "Ajuste"]

  FLOW_TYPES = {
    "Egreso"    => "expense",
    "Ingreso"   => "income"
   }

  #FILTROS DE BUSQUEDA
    def self.search_by_user user
      if !user.blank?
        where(user_id: user)
      else
        all
      end
    end

    def self.search_by_payment_type payment_type
      if !payment_type.nil?
        where(payment_type: payment_type)
      else
        all
      end
    end
  #FILTROS DE BUSQUEDA

  #ATRIBUTOS
  	def flow_type
  		case flow
  		when "income"
  			"Ingreso"
  		when "expense"
  			"Egreso"
  		when "neutral"
        "Neutro"
      else
  			"-"
  		end
  	end

    def user_name
      user.nil? ? "Generado por sistema" : user.name
    end

    def user_avatar
      user.nil? ? "/images/default_user.png" : user.avatar
    end

    def associated_document_link
      if not payment_id.nil?
        case flow
        when "income"
          "/invoices/#{payment.invoice_id}/edit" unless payment.invoice_id.nil?
        when "expense"
         "/purchase_orders/#{payment.purchase_order_id}/edit" unless payment.purchase_order_id.nil?
        end
      end
    end
  #ATRIBUTOS

  #PROCESOS

    def set_initial_values
      if new_record?
        if flow == "income"
          self.current_balance       =  daily_cash.current_amount.to_f + self.amount
        else
          self.current_balance       =  daily_cash.current_amount.to_f - self.amount
        end
      end
    end

  	def self.save_from_payment payment, company_id
      invoice_tipo = Invoice.where(id: payment.invoice_id).first.try(:cbte_tipo)
      unless Invoice::COD_NC.include?(invoice_tipo)
        pp "ENTRO A SAVE FROM PAYMENT"
        daily_cash = DailyCash.current_daily_cash(company_id)
    		movement = where(daily_cash_id: daily_cash.id, payment_id: payment.id).first_or_initialize
    		movement.movement_type 			   =  "Pago"
    		movement.amount 				       =  payment.total
    		movement.associated_document 	 =  payment.associated_document
    		movement.payment_type			     =  payment.type_of_payment
    		movement.flow 					       =  payment.flow
    		movement.payment_id 			     =  payment.id
        movement.user_id               =  payment.user_id
        if movement.new_record?
          if payment.flow == "income"
            movement.current_balance       =  daily_cash.current_amount.to_f + payment.total
          else
            movement.current_balance       =  daily_cash.current_amount.to_f - payment.total
          end
        end
    		movement.save unless !movement.changed?
      end
  	end

    def touch_daily_cash_current_amount
      daily_cash.update_current_amount
    end

    def set_daily_cash
      self.daily_cash_id ||= DailyCash.current_daily_cash(User.find(self.user_id).company_id).id
    end

    def set_payment_type
       self.payment_type ||= "0"
    end

    def fix_balance_on_update
      dif = amount - amount_was
      if flow == "expense"
        dif = -dif
      end
      update_others_movements(dif)
    end

    def fix_balance_on_destroy
      update_others_movements(-amount)
      if movement_type == "Apertura de caja"
        if daily_cash.daily_cash_movements.count > 1
          throw :abort
        end
      elsif movement_type == "Cierre de caja"
        daily_cash.update_column(:state, "Abierta")
      end
    end

    def update_others_movements dif
      if dif != 0.0
        next_movements = DailyCashMovement.where("created_at >= ? AND daily_cash_id = ?", created_at, daily_cash_id)
        next_movements.each do |dcm|
          balance = dcm.current_balance + dif
          dcm.update_column(:current_balance, balance)
        end
      end
    end
  #PROCESOS
end
