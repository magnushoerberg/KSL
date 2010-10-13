require 'sinatra/base'
require 'sass'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'session_auth'
require "sinatra/reloader"
require 'passwords.rb'

class Kroken
	include DataMapper::Resource
	property :id, Serial
	property :date, DateTime
	
	has n, :dutys
end

class Duty
	include DataMapper::Resource
	
	property :id, Serial
	property :type, String
	property :worker, String
	
	belongs_to :kroken
end

class DaKroken < Sinatra::Base
	use Rack::MethodOverride
	register Sinatra::SessionAuth
	enable :sessions
	
	set :username, USERNAME
	set :password, PASSWORD
	
	helpers do
		def partial(template, duty)
			@duty = duty
			haml template, :layout=> false
		end
	end
	
	configure :production do 
		DataMapper.setup(:default, ENV['DATABASE_URL']) 
	end

	configure :development do
		DataMapper::Logger.new($stdout, :debug)
		DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/dev.db")
		register Sinatra::Reloader
	end

	configure do
		DataMapper.finalize
		DataMapper.auto_upgrade!
	end
	
	get '/' do
		authorize!
		@krokar = Kroken.all(:date.gte => Date.today, :order => :date.asc)
		haml :index
	end
	
	delete '/remove' do
		duty = Duty.get(params[:id])
		duty.destroy
		redirect '/'
	end
	
	get '/style.css' do
		content_type 'text/css'
		sass :style
	end
	
	get '/logout' do
		logout!
		redirect '/'
	end
	
	post '/schedule' do
		@kroken = Kroken.first_or_create(:date => Date.parse(params[:datepicker]))
		@kroken.save
		haml :schedule
	end
	
	post '/booking' do
		unless params[:fridge].empty? then
			@fridge = Duty.first_or_create(:type => "fridge", :kroken => Kroken.get(params[:id]), :worker => params[:fridge])
			@fridge.save
		end
		unless params[:carry].empty? then
			@carry = Duty.first_or_create(:type => "carry", :kroken => Kroken.get(params[:id]), :worker => params[:carry])
			@carry.save
		end
		unless params[:bar].empty? then
			@bar = Duty.first_or_create(:type => "bar", :kroken => Kroken.get(params[:id]), :worker => params[:bar])
			@bar.save
		end
		unless params[:chef].empty? then
			@chef = Duty.first_or_create(:type => "chef", :kroken => Kroken.get(params[:id]), :worker => params[:chef])
			@chef.save
		end
		redirect '/'
	end
end

if __FILE__ == $0
   DaKroken.run! :host => 'localhost', :port => 9393
end