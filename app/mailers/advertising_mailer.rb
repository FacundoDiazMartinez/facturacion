class AdvertisingMailer < ApplicationMailer
  default from: "facturacionlitecode@gmail.com"

  def advertising_email(clients, advertisement)
    @clients_emails_with_names = []

    clients.each do |c|
      Client.find(c).client_contacts.each do |contact|
        @clients_emails_with_names << %("#{contact.name}" <#{contact.email}>)
      end
    end
    pp @clients_emails_with_names
    @advertisement = advertisement
    mail(to: @clients_emails_with_names, subject: 'Email de prueba')
  end
end
