class Payment < ApplicationRecord
  has_one :delayed_job, dependent: :destroy

  after_initialize :set_payment_date
  after_save :save_daily_cash_movement

  default_scope { where(active: true) }

  TYPES = {
  	"0" => "Contado",
  	"1" => "Tarjeta de crédito",
  	"2" => "Tarjeta de débito",
  	"3" => "Transferencia bancaria",
  	"4" => "Cheque",
  	"5" => "Retenciones"
  }

  #ATRIBUTOS
    def payment_name
      TYPES[type_of_payment]
    end

    def associated_document
      pp self
      if !invoice_id.nil?
        pp invoice.name_with_comp
      elsif !purchase_order_id.nil?
        pp purchase_order.name_with_comp
      else
        pp ""
      end
    end

    def user_id
      if !invoice_id.nil?
        invoice.user_id
      elsif !purchase_order_id.nil?
        purchase_order.user_id
      else
        nil
      end
    end

    def company
      if !invoice_id.nil?
        invoice.company
      else
        purchase_order.company
      end
    end
  #ATRIBUTOS

  #PROCESOS
    def set_payment_date
      self.payment_date ||= Date.today
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end

    def save_daily_cash_movement
      if type_of_payment == "0"
        if payment_date <= Date.today
          DailyCashMovement.save_from_payment(self, company.id)
        else
          DailyCashMovement.delay(run_at: payment_date).save_from_payment(self, company.id)
        end
      end
    end
  #PROCESOS

  #FUNCIONES
    def self.set_payment
      any? ? all : new
    end
  #FUNCIONES
end
