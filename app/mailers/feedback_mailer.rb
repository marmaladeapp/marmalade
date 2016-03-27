class FeedbackMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_mailer.contact_form.subject
  #
  def feedback_form(email)
    @email = email

    mail_to = "thomfilms@gmail.com"

    mail to: mail_to, from: "#{email.name} <#{email.email}>", subject: 'Marmalade Feedback | ' + email.subject
  end
end
