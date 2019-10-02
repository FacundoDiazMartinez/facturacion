module Subpayment
	extend ActiveSupport::Concern

  included do
    after_destroy :update_invoice
		belongs_to :payment

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
    payment.update_column(:total, self.total)
  end

  def client
    payment.client
  end

	def generator_name
		payment.user_id.blank? ? "Sistema" : payment.user.name
	end

  def account_movement_payment
    AccountMovementPayment.find_by_id(self.payment_id)
  end

  def update_invoice
		unless payment.nil?
	  	if not self.payment.invoice_id.blank?
	  		Invoice.find(self.payment.invoice_id).touch
	  	end
		end
  end
end
