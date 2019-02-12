class SendedAdvertisement < ApplicationRecord
  belongs_to :advertisement
  after_create :send_mail

  def send_mail
  	AdvertisingMailer.advertising_email(self).deliver_now
  	upadte_advertisement_state
  end

  def upadte_advertisement_state
    self.advertisement.update_column(:state, "Enviado")
    self.advertisement.update_column(:delivery_date, Date.today)
  end
end
