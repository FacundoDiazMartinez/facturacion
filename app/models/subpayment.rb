module Subpayment
	extend ActiveSupport::Concern

  included do
    before_validation :update_payment
    after_destroy :update_invoice
  end

  def update_payment
    payment.update(total: self.total)
  end

  def update_invoice
  	if not self.payment.invoice_id.blank?
  		self.payment.invoice.touch
  	end
  end
end