class ApplicationMailer < ActionMailer::Base
  default from: "support@yellowmountain.io"
  layout 'email/email'
end
