class AdvertisingMailer < ApplicationMailer
  default from: "facturacionlitecode@gmail.com"

  def advertising_email(sended_advertisement)
    @clients_emails_with_names = []

    sended_advertisement.clients_data.split(',').each do |c|
      Client.find(c).client_contacts.each do |contact|
        @clients_emails_with_names << %("#{contact.name}" <#{contact.email}>)
      end
    end
    @advertisement = sended_advertisement.advertisement
    mail(to: @clients_emails_with_names, subject: "Últimas promociones y descuentos de #{sended_advertisement.advertisement.company.name}")
  end
end
