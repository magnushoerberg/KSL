require 'sinatra/base'
require 'pony'

module Sinatra
  module MailService
    :subject
    :html_body
    module Helpers
      def set_subject subject
        @subject = subject
      end

      def set_body html
        @html_body = html
      end

      def send_mail receiver
        Pony.mail(:to => receiver, :subject=> @subject, :html_body=> @html_body, :body => "hello", :via=> :smtp, :via_options=> {
              :address => "smtp.sendgrid.net",
              :from => "magnus.hoerberg@gmail.com",
              :port => "25",
              :authentication => :plain,
              :user_name => ENV['SENDGRID_USERNAME'],
              :password => ENV['SENDGRID_PASSWORD'],
              :domain => ENV['SENDGRID_DOMAIN' ]
            })
      end
    end
    def self.registered(app)
      app.helpers MailService::Helpers

      app.get '/sendmail' do
        @kroken = Kroken.first(:date => Date.today)
        set_subject "hello"
        set_body partial(:"/partials/kroken_partial", @kroken)
        send_mail "magnus.hoerberg@gmail.com"
      end
    end
  end
  register MailService
end
