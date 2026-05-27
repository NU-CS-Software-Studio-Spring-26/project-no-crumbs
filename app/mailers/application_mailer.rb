class ApplicationMailer < ActionMailer::Base
  default from: "No Crumbs <#{ENV.fetch('GMAIL_USERNAME', 'notifications@no-crumbs.app')}>"
  layout "mailer"
end
