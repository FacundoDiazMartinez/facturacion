class SendedAdvertisement < ApplicationRecord
  belongs_to :advertisement
  after_create :send_mail
  validate :check_clients_data

  def send_mail
  	AdvertisingMailer.advertising_email(self).deliver_now
  	upadte_advertisement_state
  end

  def upadte_advertisement_state
    self.advertisement.update_column(:state, "Enviado")
    self.advertisement.update_column(:delivery_date, Date.today)
  end

  def check_clients_data
    errors.add(:clients_data, "Debe seleccionar al menos un destinatario.") unless not clients_data.blank?
  end

end
