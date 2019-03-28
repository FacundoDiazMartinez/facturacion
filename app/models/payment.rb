class Payment < ApplicationRecord
  include Deleteable
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :client, optional: true #TODO VINCULAR

  has_one :delayed_job, dependent: :destroy
  has_one :daily_cash_movement, dependent: :destroy

  has_one :cash_payment, dependent: :destroy
  has_one :card_payment, dependent: :destroy
  has_one :bank_payment, dependent: :destroy
  has_one :debit_payment, dependent: :destroy
  has_one :cheque_payment, dependent: :destroy
  has_one :retention_payment, dependent: :destroy

  after_initialize :set_payment_date
  after_save :save_daily_cash_movement

  default_scope { where(active: true) }
  accepts_nested_attributes_for :cash_payment, reject_if: Proc.new{|p| p["total"].to_f == 0}, allow_destroy: true
  accepts_nested_attributes_for :card_payment, reject_if: Proc.new{|p| p["total"].to_f == 0}, allow_destroy: true
  accepts_nested_attributes_for :bank_payment, reject_if: Proc.new{|p| p["total"].to_f == 0}, allow_destroy: true
  accepts_nested_attributes_for :debit_payment, reject_if: Proc.new{|p| p["total"].to_f == 0}, allow_destroy: true
  accepts_nested_attributes_for :cheque_payment, reject_if: Proc.new{|p| p["total"].to_f == 0}, allow_destroy: true
  accepts_nested_attributes_for :retention_payment, reject_if: Proc.new{|p| p["total"].to_f == 0}, allow_destroy: true

  validate :min_total, on: :create
  validates_numericality_of :total, greater_than: 0.0, message: "El monto pagado debe ser mayor 0."

  TYPES = {
  	"0" => "Contado",
  	"1" => "Tarjeta de crédito",
  	"3" => "Transferencia bancaria",
  	"4" => "Cheque",
  	"5" => "Retenciones",
    "6" => "Cuenta Corriente",
    "7" => "Tarjeta de débito"
  }

  #VALIDACIONES
    def min_total
      #self.mark_for_destruction unless total > 0
    end
  #VALIDACIONES

  #ATRIBUTOS
    def cash_payment_attributes=(attribute)
      self.total = attribute["total"].to_f
      #super
    end

    def debit_payment_attributes=(attribute)
      self.total = attribute["total"].to_f
      #super
    end

    def card_payment_attributes=(attribute)
      self.total = attribute["total"]
      self.credit_card_id = attribute["credit_card_id"]
      super
    end

    def bank_payment_attributes=(attribute)
      self.total = attribute["total"]
      #super
    end

    def cheque_payment_attributes=(attribute)
      self.total = attribute["total"]
      #super
    end

    def retention_payment_attributes=(attribute)
      self.total = attribute["total"]
      #super
    end

    def payment_name
      TYPES[type_of_payment]
    end

    def associated_document
      if !invoice_id.nil?
        invoice.name_with_comp
      elsif !purchase_order_id.nil?
        purchase_order.name_with_comp
      elsif !account_movement_id.nil?
        am = AccountMovement.unscoped.find(account_movement_id)
        if am.receipt_id.nil?
          ""
        else
          am.receipt.full_name
        end
      else
        ""
      end
    end

    # def user_id
    #   if !invoice_id.nil?
    #     invoice.user_id
    #   elsif !purchase_order_id.nil?
    #     purchase_order.user_id
    #   else
    #     nil
    #   end
    # end

    def company
      if !invoice_id.nil?
        invoice.company
      elsif !purchase_order_id.nil?
        purchase_order.company
      else
        account_movement.receipt.company
      end
    end

    def client
      Client.unscoped{ super }
    end

  #ATRIBUTOS

  #PROCESOS
    def set_payment_date
      self.payment_date ||= Date.today
    end

    def save_daily_cash_movement
      pp "ENTRO A SAVE DAILY CASH MOVEMENT"
      if type_of_payment == "0"
        if payment_date <= Date.today
          DailyCashMovement.save_from_payment(self, company_id)
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

    def changed_or_new_record?
      !saved_changes.empty? || created_at == updated_at
    end

    def type_of_payment_name
      case type_of_payment.to_i
      when 0
        "cash_payments"
  		when 1
          "card_payments"
  		when 3
          "bank_payments"
  		when 4
          "cheque_payments"
  		when 5
          "retention_payments"
  		when 6
          "account_payments"
  		when 7
          "debit_payments"
      end
    end
  #FUNCIONES
end
