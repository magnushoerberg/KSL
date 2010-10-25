require 'sinatra/base'
require 'pony'

module Sinatra
  module MailService
    :subject
    module Helpers
      def set_subject subject
        @subject = subject
      end

      def send_mail receiver
        Pony.mail(:to => receiver, :subject=> @subject, :body => "<h1>hello</h1>", :via=> :smtp, :via_options=> {
              :address => "smtp.sendgrid.net",
              :from => "magnus.hoerberg@gmail.com",
              :port => "25",
              :authentication => :plain,
              :user_name => ENV['SENDGRID_USERNAME'],
              :password => ENV['SENDGRID_PASSWORD'],
              :domain => ENV['SENDGRID_DOMAIN' ],
            })
      end
    end
    def self.registered(app)
      app.helpers MailService::Helpers

      app.get '/sendmail' do
        set_subject "hello"
        send_mail "magnus.hoerberg@gmail.com"
      end
    end
  end
  register MailService
end
