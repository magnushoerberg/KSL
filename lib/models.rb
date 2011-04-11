require 'dm-core'

class Bokning
	include DataMapper::Resource

	property :id, Serial
	property :namn, String
	property :till, DateTime
	property :fran, DateTime

	has n, :ordrar, "Order"
end
class Order
	include DataMapper::Resource

	property :id, Serial
	has n, :artiklar, "Artikel", :throught => Resource
	belongs_to :bokning
end
class Artikel
	include DataMapper::Resource

	property :id, Serial
	property :namn, String
	property :pris, Float

	has n, :order, "Order", :throught => Resource
end

class Ol < Artikel; end
class Cider < Artikel; end

DataMapper.finalize
