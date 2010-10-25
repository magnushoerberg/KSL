
task :cron do
  require 'user_mail_service.rb'
  require 'app.rb'
     @kroken = Kroken.first(:date => Date.today)
     set_subject "hello"
     set_body partial(:"/partials/kroken_partial", @kroken)
     send_mail "magnus.hoerberg@gmail.com"
end
