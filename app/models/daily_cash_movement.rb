class DailyCashMovement < ApplicationRecord
  belongs_to :daily_cash, touch: true
  belongs_to :user, optional: true
  belongs_to :payment, optional: true

  after_initialize  :set_daily_cash
  before_save       :fix_balance_on_update, if: Proc.new{|dcm|  !dcm.new_record?}
  after_save        :touch_daily_cash_current_amount
  before_destroy    :fix_balance_on_destroy
  after_destroy     { |movement| movement.touch_daily_cash_current_amount }
  before_validation :set_payment_type

  default_scope { where(active: true ) }


  TYPES = ["Pago", "Ajuste"]

  FLOW_TYPES = {
    "Egreso"    => "expense",
    "Ingreso"   => "income"
   }

   def self.default_scope
     left_joins(payment: :purchase_order).where("purchase_orders.state = 'Finalizada' OR payments.purchase_order_id IS NULL")
   end

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
            if !payment.invoice_id.nil?
              "/invoices/#{payment.invoice_id}/edit"
            else
              if !payment.account_movement.receipt_id.nil?
                "/receipts/#{payment.account_movement.receipt_id}/edit"
              end
            end
          when "expense"
           "/purchase_orders/#{ExpensePayment.unscoped.find(payment_id).purchase_order_id}/edit" unless ExpensePayment.unscoped.find(payment_id).purchase_order_id.nil?
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

    ## genera movimientos de caja diaria para recibos confirmados
    def self.generate_from_receipt receipt
      if receipt.confirmado?
        receipt.account_movement_payments.each do |payment|
          if payment.type_of_payment == "0"
            if payment.payment_date == Date.today
              save_from_payment payment, receipt.company_id
            end
          end
        end
      end
    end

    ## guarda un movimiento de caja diaria para pagos de contado con comprobantes CONFIRMADOS
  	def self.save_from_payment payment, company_id
      if payment
        invoice     = Invoice.where(id: payment.invoice_id).first
        daily_cash  = DailyCash.current_daily_cash(company_id) #caja del día
        movement    = self.where(daily_cash_id: daily_cash.id, payment_id: payment.id).first_or_initialize
        movement.movement_type 			   =  "Pago"
        movement.amount 				       =  payment.total
        movement.associated_document 	 =  payment.associated_document
        movement.payment_type			     =  payment.type_of_payment
        if invoice.nil?
          movement.flow 					   =  payment.flow
        else
          movement.flow 					   =  invoice.is_credit_note? ? "expense" : payment.flow
        end
        movement.payment_id 			     =  payment.id
        movement.user_id               =  payment.user_id
        if movement.new_record?
          if payment.flow == "income"
            movement.current_balance       =  daily_cash.current_amount.to_f + payment.total
          else
            movement.current_balance       =  daily_cash.current_amount.to_f - payment.total
          end
        end
        movement.save# if movement.changed?
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
        next_movements = DailyCashMovement.where("daily_cash_movements.created_at >= ? AND daily_cash_movements.daily_cash_id = ?", created_at, daily_cash_id)
        next_movements.each do |dcm|
          balance = dcm.current_balance + dif
          dcm.update_column(:current_balance, balance)
        end
      end
    end

    def destroy
    	update_column(:active, false)
    	run_callbacks :destroy
    end
  #PROCESOS
end
