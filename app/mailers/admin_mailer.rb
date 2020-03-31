class AdminMailer < ApplicationMailer
	default from: 'from@example.com'
  layout 'mailer'

  def new_user_waiting_for_approval(email)
    @email = email
    mail(to: email, subject: "Una persona solicita unirse a tu compañía.")
  end
end
