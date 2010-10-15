require 'sinatra/base'

module Sinatra
  module SessionAuth

    module Helpers
      def authorized?
        session[:authorized]
      end
	  
	  def admin?
		session[:admin]
	  end

      def authorize!
        redirect '/login' unless authorized?
      end

      def logout!
		session[:admin] = false
        session[:authorized] = false
      end
    end

    def self.registered(app)
      app.helpers SessionAuth::Helpers

      app.get '/login' do
        haml :login
      end

      app.post '/login' do
		user = User.first(:name=> params[:user] )
		if user.nil?
			session[:authorized] = false
			redirect '/login'
        elsif params[:pass] == user.password
			session[:admin] = false
			session[:admin] = true if user.name == "Magnus"
			session[:userid] = user.id
			session[:authorized] = true
			redirect '/'
        else
			session[:authorized] = false
			redirect '/login'
        end
      end
    end
  end

  register SessionAuth
end