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

    def payment_name
      TYPES[type_of_payment]
    end

    def associated_document
      if !invoice_id.nil?
        invoice.name_with_comp
      else
        purchase_order.name_with_comp
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
      if payment_date == Date.today
        DailyCashMovement.save_from_payment(self)
      else
        DailyCashMovement.delay(run_at: payment_date).save_from_payment(self)
      end
    end
  #PROCESOS

  #FUNCIONES
    def self.set_payment
      any? ? all : new
    end
  #FUNCIONES
end
