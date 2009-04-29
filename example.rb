
require 'rubygems'
require 'resourceful'
require 'dm-core'
require 'lib/dm-ssbe-adapter'

DataMapper.setup(:default, :adapter => :ssbe,
                           :username => 'admin',
                           :password => 'admin',
                           :services_uri => 'http://auth.v6.localhost/services',
                           :logger => Resourceful::StdOutLogger.new)


puts "GET Service"
puts Service.get("http://auth.v6.localhost/services/AllAccounts").inspect

puts "All Services"
puts Service.all.inspect

puts "Create Service"
s = Service.create(:name => "OtherAccounts",
                   :resource_href => "http://auth.v6.localhost/services/AllOtherAccounts")

puts s.inspect

puts "Update Service"
s.resource_href = "http://auth.v6.localhost/services/OtherAccounts"
s.save
puts s.inspect


