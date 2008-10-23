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
end

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

# This creates tabes if using SQL or domains if using simpledb

db_config =  File.open('config/database.yml'){|yf| YAML::load(yf)}[:test]

# Temporary workaround untill I pull auto_migrate from Edward's fork.
if db_config[:adapter] == 'simpledb'
  AwsSdb::Service.new(
    :access_key_id => db_config[:access_key],
    :secret_access_key => db_config[:secret_key],
    :url => db_config[:url]
  ).create_domain('panda_test')
else
  DataMapper.auto_migrate!
end


Spec::Runner.configure do |config|
  config.include(Merb::Test::ViewHelper)
  config.include(Merb::Test::RouteHelper)
  config.include(Merb::Test::ControllerHelper)
end
