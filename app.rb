# encoding: ISO-8859-1
require 'sinatra/base'
require 'sass'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'session_auth'
require 'passwords.rb'
require 'models'

class KrokenViewModel
	attr_accessor :type, :date, :workers

	def initialize(type, date, worker)
		@type = type
		@date = date
		@workers = []
		@workers.push(worker)
	end
end

class DaKroken < Sinatra::Base
	use Rack::MethodOverride
	register Sinatra::SessionAuth
	enable :sessions
	
	helpers do
		def partial(template, duty)
			@duty = duty
			haml template, :layout=> false
		end
		
		def make_kroken_viewmodel
			@view_models = []
			duties = Duty.all
			for duty in duties
				if @view_models.select {|a| a.type == duty.type && a.date == duty.kroken.date}.empty?
					@view_models.push(KrokenViewModel.new(duty.type, duty.kroken.date, duty.worker))
				else
					@view_models.select {|a| a.type == duty.type && a.date == duty.kroken.date}.first.workers.push(duty.worker)
				end
				@view_models
			end
			@view_models
		end
		
		def make_sentence(duty)
			if duty.type == "fridge"
				sentence = duty.worker + " kan inte fylla kylarna"
			elsif duty.type == "carry"
				sentence = duty.worker+ " kan inte bära barer"
			elsif duty.type == "bar"
				sentence = duty.worker + " kan inte jobba i baren"
			elsif duty.type == "chef"
				sentence = duty.worker + " kan inte vara kökschef"
			elsif duty.type == "clean"
				sentence = duty.worker + " kan inte städa"
			end
			sentence
		end
	end
	
	configure :production do 
		DataMapper.setup(:default, ENV['DATABASE_URL']) 
	end

	configure :development do
		require "sinatra/reloader"
		DataMapper::Logger.new($stdout, :debug)
		DataMapper.setup(:default, "sqlite://#{Dir.pwd}/dev.db?encoding=utf8")
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
		duty = Duty.first(params[:id], params[:kroken_id], session[:userid])
		duty.destroy
		redirect '/'
	end
	
	get '/remove/user' do
		@users = User.all
		haml :remove_user
	end
	
	delete '/remove/user' do
		User.all(:id => params[:name].to_i).destroy
		redirect '/personal'
	end
	
	get '/style.css' do
		content_type 'text/css'
		sass :style
	end
	
	get '/logout' do
		logout!
		redirect '/login'
	end
	
	post '/schedule' do
		@kroken = Kroken.first_or_create(:date => Date.parse(params[:datepicker]))
		@kroken.save
		haml :schedule
	end
	
	post '/user' do
		@user = User.create(:name => params[:user], :password=> params[:pass])
		if @user.save
			redirect '/'
		else
			redirect '/personal'
		end
	end
	
	get '/personal' do
		authorize!
		@duties = Duty.all(:user_id => session[:userid])
		if session[:admin]
			haml :admin
		else
			haml :user
		end
	end
	
	post '/booking' do
		unless params[:fridge].empty? then
			@fridge = Duty.first_or_create(:type => "fridge", :kroken => Kroken.get(params[:id]), :worker => params[:fridge], :user_id=> session[:userid])
			@fridge.save
		end
		unless params[:carry].empty? then
			@carry = Duty.first_or_create(:type => "carry", :kroken => Kroken.get(params[:id]), :worker => params[:carry], :user_id=> session[:userid])
			@carry.save
		end
		unless params[:bar].empty? then
			@bar = Duty.first_or_create(:type => "bar", :kroken => Kroken.get(params[:id]), :worker => params[:bar], :user_id=> session[:userid])
			@bar.save
		end
		unless params[:chef].empty? then
			@chef = Duty.first_or_create(:type => "chef", :kroken => Kroken.get(params[:id]), :worker => params[:chef], :user_id=> session[:userid])
			@chef.save
		end
		unless params[:clean].empty? then
			@clean = Duty.first_or_create(:type=> "clean", :kroken => Kroken.get(params[:id]), :worker => params[:clean], :user_id=> session[:userid])
			@clean.save
		end
		redirect '/'
	end
end

if __FILE__ == $0
   DaKroken.run! :host => 'localhost', :port => 9393
end