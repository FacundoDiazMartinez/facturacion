class AdvertisingMailer < ApplicationMailer
  default from: "facturacionlitecode@gmail.com"

  def advertising_email(client, advertisement)
    @user = client
    @advertisement = advertisement
    mail(to: @user.email, subject: 'Email de prueba')
  end
end
