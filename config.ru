require 'rubygems'
require "bundler/setup"

require 'sinatra'
require 'sinatra/reloader'
require 'dm-core'
require 'haml'

require './app'
require './models'

run DaKroken
