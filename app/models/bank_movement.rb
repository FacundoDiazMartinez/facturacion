class BankMovement < Payment
  include Subpayment
  self.table_name = "payments"

  def self.default_scope
    where(type_of_payment: ["3", "7"], active: true)
  end

  def self.search_by_bank bank
    if !bank.blank?
      where("banks.name = ?", bank)
    else
      all
    end
  end

  def bank
    if type_of_payment == "3"
      bank_payment.bank
    else
      debit_payment.bank
    end
  end

  def tipo
    if type_of_payment == "3"
      "Transferencia bancaria"
    else
      "Pago con débito"
    end
  end

  def payment
    self
  end

end
