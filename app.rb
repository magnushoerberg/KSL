class DaKroken < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :haml, :format => :html5
  configure :production do 
    DataMapper.setup(:default,ENV['DATABASE_URL']) 
  end
  configure :development do
    require "sinatra/reloader"
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, "sqlite://#{Dir.pwd}/dev.db?encoding=utf8")
    register Sinatra::Reloader
  end
  before do
    content_type :html, :charset=> 'utf-8'
  end
	get '/' do
		@bokningar = Bokning.all.collect{|b|
			{:namn => b.namn, :id => b.id}
		}
		redirect '/bokning/ny' if @bokning.nil?
		haml :index
	end
	get '/bokning/ny' do
		haml :bokning
	end
	post '/bokning/ny' do
		b = Bokning.create params
		redirect "/order/#{b.id}/ny"
	end
	get '/order/:bokning_id/ny' do
		haml :order
	end
	post '/order/:bokning_id/ny' do
		Order.create params
	end
end
