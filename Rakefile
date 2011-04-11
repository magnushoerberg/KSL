require 'rake'

namespace :db do
	task :environment do
		require 'dm-core'
		require "#{Dir.pwd}/models.rb"
		DataMapper.setup(:default,ENV['DATABASE_URL']||"sqlite://#{Dir.pwd}/dev.db")
		DataMapper.finalize
	end
	task :migrate => :environment do
		require 'dm-migrations'
		DataMapper.auto_migrate!
	end
	namespace :load do
		task :items do
			def parse_csv(row, type)
				namn, pris = row
				type.first_or_create(:namn => namn).update(:price => pris)
			end
			CSV.open('ol.csv','r',',') do |row|
				parse_csv(row,Ol)
			end
			CSV.open('cider.csv','r',',') do |row|
				parse_csv(row,Cider)
			end
		end
	end
end
