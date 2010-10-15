require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

class Kroken
	include DataMapper::Resource
	property :id, Serial
	property :date, Date
	
	has n, :dutys
end

class User
	include DataMapper::Resource
	
	property :id, Serial
	property :name, String, :required=> true, :unique=> true
	property :password, String, :required=> true
	
	has n, :dutys
end

class Duty
	include DataMapper::Resource
	
	property :id, Serial
	property :type, String
	property :worker, String
	
	property :kroken_id,   Integer, :key => true, :min => 1
    property :user_id, Integer, :key => true, :min => 1
	
	belongs_to :kroken, :key=> true
	belongs_to :user, :key=> true
end