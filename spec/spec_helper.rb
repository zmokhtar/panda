require 'rubygems'
require 'merb-core'
require 'spec' # Satiates Autotest and anyone else not using the Rake tasks

require 'simplerdb/server'
require 'aws_sdb'

# Start up in memory simplerdb for testing. This is only used if you set up 
# simpledb with these settings in database.yml.
# Check for @server first or it tries to start many copies.
@server || begin
  @server = SimplerDB::Server.new(8097)
  @thread = Thread.new { @server.start }
  AwsSdb::Service.new(:access_key_id => '1', :secret_access_key => '2', :url => 'http://localhost:8097').create_domain("panda_test")
end

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end
