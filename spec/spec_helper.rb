
require 'rubygems'
require 'thin'
require 'pp'

require '../../dm-core/lib/dm-core'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'dm-ssbe-adapter'
require 'dm-ssbe-adapter/model_extensions'

DataMapper.setup(:default, :adapter => :ssbe,
                 :username => 'admin',
                 :password => 'admin',
                 :services_uri => 'http://localhost:5050/services',
                 #:logger => Resourceful::StdOutLogger.new)
                 :logger => Resourceful::BitBucketLogger.new)

require 'models'
require 'simple_sinatra_server'

@server = Thread.new do

  Thin::Server.start('0.0.0.0', 5050, App, :debug => false)

end unless @server

at_exit { @server.exit }

# Give the app a change to initialize
$stderr.puts "Waiting for thin to initialize..."
sleep 0.2

