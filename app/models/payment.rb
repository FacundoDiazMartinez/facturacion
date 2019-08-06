class Payment < ApplicationRecord
  include Deleteable
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :client, optional: true #TODO VINCULAR
  belongs_to :purchase_order, optional: true
  belongs_to :invoice, optional: true

  has_one :delayed_job, dependent: :destroy
  has_one :daily_cash_movement, dependent: :destroy

  has_one :cash_payment
  has_one :card_payment
  has_one :bank_payment
  has_one :debit_payment
  has_one :cheque_payment
  has_one :retention_payment
  has_one :compensation_payment

  after_initialize  :set_payment_date
  after_validation :check_cheque_digits

  default_scope { where(active: true) }

  accepts_nested_attributes_for :cash_payment,          reject_if: :valid_nested_payment?
  accepts_nested_attributes_for :card_payment,          reject_if: :valid_nested_payment?
  accepts_nested_attributes_for :bank_payment,          reject_if: :valid_nested_payment?
  accepts_nested_attributes_for :debit_payment,         reject_if: :valid_nested_payment?
  accepts_nested_attributes_for :cheque_payment,        reject_if: :valid_nested_payment?
  accepts_nested_attributes_for :retention_payment,     reject_if: :valid_nested_payment?
  accepts_nested_attributes_for :compensation_payment,  reject_if: :valid_nested_payment?

  validates_numericality_of :total, greater_than: 0.0, message: "El monto pagado debe ser mayor 0."

  TYPES = {
  	"0" => "Contado",
  	"1" => "Tarjeta de crédito",
  	"3" => "Transferencia bancaria",
  	"4" => "Cheque",
  	"5" => "Retenciones",
    "6" => "Cuenta Corriente",
    "7" => "Tarjeta de débito",
    "8" => "Compensación"
  }

  #ATRIBUTOS
  def valid_nested_payment?
    return self["total"].to_f == 0
  end

  def account_movement
    AccountMovement.unscoped.find(account_movement_id) unless account_movement_id.blank?
  end

  def child
    if not cash_payment.nil?
      return cash_payment
    elsif not debit_payment.nil?
      return debit_payment
    elsif not card_payment.nil?
      return card_payment
    elsif not bank_payment.nil?
      return bank_payment
    elsif not cheque_payment.nil?
      return cheque_payment
    elsif not retention_payment.nil?
      return retention_payment
    elsif not compensation_payment.nil?
      return compensation_payment
    end
  end

  def cash_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "CashPayment")
    self.total = attribute["total"].to_f
    super
  end

  def debit_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "DebitPayment")
    self.total = attribute["total"].to_f
    super
  end

  def card_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "CardPayment")
    self.total = attribute["total"]
    # self.credit_card_id = attribute["credit_card_id"]
    super
  end

  def bank_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "BankPayment")
    self.total = attribute["total"]
    super
  end

  def cheque_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "ChequePayment")
    self.total = attribute["total"]
    super
  end

  def retention_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "RetentionPayment")
    self.total = attribute["total"]
    super
  end

  def compensation_payment_attributes=(attribute)
    self.child.destroy unless (self.child.nil? || self.child.class.name == "CompensationPayment")
    self.total = attribute["total"].to_f
    super
  end

  def payment_name
    TYPES[type_of_payment]
  end

  def associated_document
    if !invoice_id.nil?
      Invoice.find(invoice_id).name_with_comp
    elsif !purchase_order_id.nil?
      PurchaseOrder.find(purchase_order_id).name_with_comp
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

  def associated_document_active_record
    if !invoice_id.nil?
      Invoice.find(invoice_id)
    elsif !purchase_order_id.nil?
      PurchaseOrder.find(purchase_order_id)
    elsif !account_movement_id.nil?
      am = AccountMovement.unscoped.find(account_movement_id)
      if am.receipt_id.nil?
        nil
      else
        am.receipt
      end
    else
      nil
    end
  end

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

    ## los pagos son reflejados como movimientos de caja diaria
    ## solo para pagos de contado para comprobantes confirmados
    def save_daily_cash_movement
      if type_of_payment == "0"
        if payment_date == Date.today
          DailyCashMovement.save_from_payment(self, company_id)
        elsif payment_date > Date.today
          DailyCashMovement.delay(run_at: payment_date).save_from_payment(self, company.id)
        end
      end
    end

    def destroy
  		update_column(:active, false)
  		run_callbacks :destroy
  	end
  #PROCESOS

  #FUNCIONES
    def check_cheque_digits
      if type_of_payment == "4"
        if self.cheque_payment.number.to_i.digits.count < 8
          if invoice_id.blank?
            purchase_order.errors.add(:base, "Ingrese 8 digitos para el número de cheque")
          else
            invoice.errors.add(:base, "Ingrese 8 digitos para el número de cheque")
          end
        end
      end
    end

    def subpayment_show invoice_id
      if type_of_payment.to_i == 6
        "#"
      else
        sub_id = eval("#{type_of_payment_name.singularize}").id
        "payments_#{type_of_payment_name.singularize}_path(#{sub_id}, invoice_id: #{invoice_id})"
      end
    end

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
      when 8
          "compensation_payments"
      end
    end
  #FUNCIONES
end
