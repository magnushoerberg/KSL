require 'rubygems'
require 'app'

run Sinatra::Application
run Rack::Cascade.new [RubyOres]