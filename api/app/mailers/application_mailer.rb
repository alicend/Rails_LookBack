class ApplicationMailer < ActionMailer::Base
  default from: "Look Back Calendar <no-reply@#{Settings.email_domain}>"
  layout "mailer"
end
