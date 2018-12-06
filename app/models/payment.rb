class Payment < ApplicationRecord
  belongs_to :invoice
  has_one :delayed_job, dependent: :destroy

  after_save :set_total_pay_to_invoice
  after_save :set_notification
  after_save :check_receipt

  after_initialize :set_payment_date

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
  	def set_total_pay_to_invoice
  		invoice.update_attribute(:total_pay, invoice.sum_payments)
  	end
    def payment_name
      TYPES[type_of_payment]
    end

    def payment_name_and_subtotal
      TYPES[type_of_payment] + " " + "($ " + total.to_s + ")"
    end
  #ATRIBUTOS

  #PROCESOS
    def set_notification
      Notification.create_from_payment(self)
    end

    def set_payment_date
      self.payment_date = Date.today
    end

    def check_receipt
      r = Receipt.where(invoice_id: invoice.id).first_or_initialize
      r.total       = invoice.total_pay
      r.date        = invoice.created_at
      r.company_id  = invoice.company_id
      r.save
    end
  #PROCESOS

  #FUNCIONES
    def self.set_payment
      any? ? all : new
    end

    def destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end

  #FUNCIONES
end
