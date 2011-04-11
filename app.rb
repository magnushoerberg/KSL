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
    authorize! unless request.path_info == '/login'
  end

	get '/' do
		@bokningar = Bokning.all
		haml :index
	end
end
