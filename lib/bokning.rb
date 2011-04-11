class BokningController < Sinatra::Base
  set :haml, :format => :html5, :layout=> :"../layout"
	set :views, './views/tidbok'
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

	get '/ny' do
		haml :form
	end
	post '/ny' do
		b = Bokning.create params
		redirect "/order/#{b.id}/ny"
	end
	get '/:id' do
		@bokning = Bokning.get(params[:id]) 
		haml :bokning
	end
end
