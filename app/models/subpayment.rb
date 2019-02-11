module Subpayment
	extend ActiveSupport::Concern

  included do
    after_save :update_payment
    after_destroy :update_invoice
  end

  def update_payment
    payment.update(total: self.total)
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
    pp self.payment
  	if not self.payment.invoice_id.blank?
  		Invoice.find(self.payment.invoice_id).touch
  	end
  end
end