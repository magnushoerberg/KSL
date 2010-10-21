#encoding: utf-8
require 'sinatra/base'
require 'sass'
require 'haml'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'sinatra/jsonp'
require 'session_auth'
require 'csv_reader'
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
	register Sinatra::CsvReader
	register Sinatra::Jsonp
	set :static, enable
	set :root, File.dirname(__FILE__)
	set :haml, :format => :html5
	enable :sessions
	
	configure :production do 
		DataMapper.setup(:default,ENV['DATABASE_URL']) 
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
	
	before do
		content_type :html, :charset=> 'utf-8'
		authorize! unless request.path_info == '/login'
	end
	helpers Sinatra::Jsonp	
	helpers do
		def partial(template, duty)
			
			@duty = duty
			haml template, :layout=> false
		end
		
		def make_kroken_viewmodel(date)
			@view_models = []
			duties = Duty.all
			for duty in duties
				if @view_models.select {|a| a.type == duty.type && a.date == duty.kroken.date}.empty?
					@view_models.push(KrokenViewModel.new(duty.type, duty.kroken.date, duty.worker))
				else
					@view_models.select {|a| a.type == duty.type && a.date == duty.kroken.date}.first.workers.push(duty.worker)
				end
			end
			@view_models.each { |model| 
				case model.type
					when "fridge"
						model.type = "Fylla kylen gör"
					when "carry"
						model.type = "Bära barer gör"
					when "bar"
						model.type = "Står i baren gör"
					when "chef"
						model.type = "Står i köket gör"
					when "clean"
						model.type = "Städar gör"
				end
			}
			@view_models.select{|model| model.date == date}
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
	
	get '/' do
		@krokar = Kroken.all(:date.gte => Date.today, :order => :date.asc)
		haml :index
	end
	
	delete '/remove' do
		duty = Duty.get(params[:id], params[:kroken_id], session[:userid])
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
	
	get '/schedule' do
		@date = params[:datepicker]
		@order = Order.first(:date => params[:datepicker])
		haml :schedule
	end
	
	get '/schedule/:datepicker' do
		@date = params[:datepicker]
		@order = Order.first(:date => params[:datepicker])
		haml :schedule
	end
	
	post '/schedule' do
		kroken = Kroken.first_or_create(:date => Date.parse(params[:date].to_s))
		kroken.save
		unless params[:fridge].empty? then
			@fridge = Duty.first_or_create(:type => "fridge", :kroken => kroken, :worker => params[:fridge], user_id=> session[:userid])
			@fridge.save
		end
		unless params[:carry].empty? then
			@carry = Duty.first_or_create(:type => "carry", :kroken => kroken, :worker => params[:carry], :user_id=> session[:userid])
			@carry.save
		end
		unless params[:bar].empty? then
			@bar = Duty.first_or_create(:type => "bar", :kroken => kroken, :worker => params[:bar], :user_id=> session[:userid])
			@bar.save
		end
		unless params[:chef].empty? then
			@chef = Duty.first_or_create(:type => "chef", :kroken => kroken, :worker => params[:chef], :user_id=> session[:userid])
			@chef.save
		end
		unless params[:clean].empty? then
			@clean = Duty.first_or_create(:type=> "clean", :kroken => kroken, :worker => params[:clean], :user_id=> session[:userid])
			@clean.save
		end
		redirect '/'
	end
	
	get '/user/change' do
		haml :user_change
	end
	
	put '/user/change' do
		@user = User.all(:id => session[:userid])
		if @user.update(:password=> params[:pass])
			redirect '/personal'
		else
			User.all(:id => session[:userid]).first.name
		end
	end
	
	post '/add/user' do
		@user = User.create(:name => params[:user].force_encoding('utf-8'), :password=> params[:pass].force_encoding('utf-8'))
		if @user.save
			redirect '/'
		else
			redirect '/personal'
		end
	end
	
	get '/personal' do
		@duties = Duty.all(:user_id => session[:userid])
		if session[:admin]
			haml :admin
		else
			haml :user
		end
	end
	
	get '/make/order/:date' do
		@kroken_date  = params[:date]
		haml :orders
	end
	
	get '/return/order/:order_id' do
		@order = Order.get(params[:order_id])
		haml :return_order
	end
	
	put '/return/order' do
		order = Order.get(params[:order_id])
		request.POST.delete("order_id")
		request.POST.delete("_method")
		request.POST.each { |key,val| 
			article = order.articles.select{|article| article.name == key}.first
			article.amount = article.amount - val.to_i
			article.save
			article.destroy if article.amount.eql?(0)
		}
		redirect "/schedule/#{order.date}"
	end
	
	get '/all_articles' do
		articles = Inventory.all.collect {|article|
		if article.name[/\w.+/].include?(params[:search].to_s) 	#there is crap in the db
			{:name=> article.name, :price=> article.price}
		end
		}.compact
		jsonp articles	
	end
	
	post '/make/order' do
		kroken = Kroken.first_or_create(:date=> params[:date])
		request.POST.delete("date")
		order = Order.first_or_create(:date=> kroken.date )
		request.POST.each { |key,val| 
			inv = Inventory.first(:name=> key)
			article = Article.first_or_create(:name=> inv.name, :price=> inv.price, :order_id=> order.id)
			article.amount = article.amount + val.to_i
			article.save
			order.articles << article
		}
		order.save
		redirect "/schedule/#{params[:date]}"
	end	
end

if __FILE__ == $0
   DaKroken.run! :host => 'localhost', :port => 9393
end
