require 'pdf-reader'
require "pdf_reader.rb"
require 'sinatra/base'

module Sinatra
	module PdfParser
		module Helpers			
			def make_array path
				receiver = PageTextReceiver.new
				pdf = PDF::Reader.file(path, receiver)
				arr = receiver.content.to_s.split(/\kr/)
				arr.each {|str| 
					unless str.match(/\d/).nil?
						a = Article.create(:name => str.scan(/\D{2,}/), :price=> str.scan(/\d.\d+/).to_f)
						a.save
				}
			end
		end
		app.helpers PdfParser::Helpers
		
		app.post '/add/articles/to_db'
			if admin?
				make_array params[:path]
			else
				redirect '/'
			end
		end
	end
	register PdfParser
end