class Movement < Payment
  #include Subpayment
  self.table_name = "payments"

  def self.default_scope
    where(type_of_payment: "3").or(where(type_of_payment: "7")).where(active: true)
  end

  def self.search_by_bank bank
    if !bank.blank?
      where("banks.name = ?", bank)
    else
      all
    end
  end

  def self.search_by_date date
    if !date.blank?
      where("payments.payment_date = ?", date.to_date.strftime("%Y-%m-%d"))
    else
      all
    end
  end

  def self.search_by_client client
    if !client.blank?
      joins(payment: :client).where("LOWER(clients.name) ILIKE ?", "%#{client.downcase}%")
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

end
