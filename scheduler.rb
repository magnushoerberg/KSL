require 'sinatra/base'
require 'rufus/scheduler'

module Sinatra
  module Scheduler
    def self.registered(app)
      scheduler = Rufus::Scheduler.start_new
      
      scheduler.in '1m' do
        @kroken = Kroken.first(:date=> Date.today)
        set_subject "hello"
        set_body partial(:"/partials/kroken_partial", @kroken)
        send_mail "magnus.hoerberg@gmail.com"
      end
    end
  end
  register Scheduler
end
