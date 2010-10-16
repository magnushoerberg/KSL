require 'pdf-reader'
require "c:/users/Magnus/DA_kroken/helpers/pdf_reader.rb"

class WritePDFToDB
	attr_accessor :receiver
	def initialize
		@receiver = PageTextReceiver.new
		pdf = PDF::Reader.file("bestallning.pdf", receiver)
	end
	
	def make_array
		receiver.content.to_s.scan(/\kr/)
	end
	
	def
		
	end
end