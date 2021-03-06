class DaKroken < Sinatra::Base
  set :haml, :format => :html5
	set :views, './views'
  configure :production do 
    DataMapper.setup(:default,ENV['DATABASE_URL']) 
  end
  configure :development do
    require "sinatra/reloader"
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, "sqlite://#{Dir.pwd}/dev.db")
    register Sinatra::Reloader
  end
  before do
    content_type :html, :charset=> 'utf-8'
  end
	get '/' do
		@bokningar = Bokning.all.collect{|b| {:namn => b.namn, :id => b.id} }
		haml :index
	end
	get '/order/:bokning_id/ny' do
		haml :order
	end
	post '/order/:bokning_id/ny' do
		Order.create params
	end
end
