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

      def set_html body
        @bhtml_body = body
      end

      def send_mail receiver
        Pony.mail(:to => receiver, :subject=> @subject, :html_body=> '<h1> Hello </h1>', :body => "hello", :via=> :smtp, :via_options=> {
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
        set_html partial(:"/partials/kroken_partial", Kroken.all(:date => Date.today)).to_s
        send_mail "magnus.hoerberg@gmail.com"
      end
    end
  end
  register MailService
end
