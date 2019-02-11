module Subpayment
	extend ActiveSupport::Concern

  included do
    after_save :update_payment
    after_destroy :update_invoice
    
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
  end

  def update_payment
    payment.update(total: self.total)
  end

  def client
    payment.client
  end

  def destroy
    if self.payment.active
      self.payment.destroy
      update_column(:active, false)
      run_callbacks :destroy
      freeze
    end
  end

  

  def update_invoice
  	if not self.payment.invoice_id.blank?
  		Invoice.find(self.payment.invoice_id).touch
  	end
  end
end