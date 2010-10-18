require 'sinatra/base'

module Sinatra
	module CsvReader
		module Helpers
			def reader path
				data = File.new(path).read
				data.split("\n")
			end
		end
		def self.registered(app)
			app.helpers CsvReader::Helpers
			
			app.post '/add/articles/to_db' do
				if admin?
					Inventory.destroy
					arr = reader params[:path]
					arr.each { |article|
						article_arr = article.split(";")
						a = Inventory.first_or_create(:name=> article_arr.first.force_encoding('utf-8'), :price=> article_arr.last.to_f)
						a.save
					}
					redirect '/personal'
				else
					redirect '/'
				end
			end
		end
	end
	register CsvReader
end