# Preview all emails at http://localhost:3000/rails/mailers/advertising_mailer
class AdvertisingMailerPreview < ActionMailer::Preview

  def sample_mail_preview
    AdvertisingMailer.advertising_email(User.last,Advertisement.last)
  end

end
