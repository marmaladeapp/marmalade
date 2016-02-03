class ApplicationMailer < ActionMailer::Base
  default from: "marmalade@yellowmountain.io"
  layout 'email/email'
end
