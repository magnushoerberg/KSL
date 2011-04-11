require 'rubygems'
require "bundler/setup"

require 'sinatra'
require 'sinatra/reloader'
require 'dm-core'
require 'dm-serializer'
require 'haml'

use Rack::Static, :urls =>["/css", "/js", "/images"], :root=>"public"
Dir[Dir.pwd+"/lib/*.rb"].each{ |file| require file}

map '/bokning' do
	run BokningController
end
map '/' do
	run DaKroken
end
