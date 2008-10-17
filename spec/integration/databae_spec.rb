require 'rubygems'
require 'merb-core'

#TODO
# Create rake spec:integration spec
# Integrate rake spec:integration as part of rake spec task

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

describe "using simpledb" do
  before(:each) do
    require 'rubygems'
    require 'simplerdb/server'
    require 'aws_sdb'

    @server = SimplerDB::Server.new(8087)
    @thread = Thread.new { @server.start }

    AwsSdb::Service.new(:access_key_id => '1', :secret_access_key => '2', :url => 'http://localhost:8087').create_domain("panda_test")

    DataMapper.setup(:default, {
      :adapter => 'simpledb',
      :domain => 'panda_test',
      :url => 'http://localhost:8087',
      :access_key => '1',
      :secret_key => '2'
    })
  end

  it "should return videos at processing or queued" do
    pending
    mock_video(:id => UUID.new, :status => 'queued').save
    mock_video(:id => UUID.new, :status => 'processing').save
    mock_video(:id => UUID.new, :status => 'original').save

    queued_encodings = Video.queued_encodings
    queued_encodings.should have(2).videos
    queued_encodings.each{|e| e.status.should_not == 'original'}
  end

  after(:each) do
   # All entry will disappear when server is broght down 
   # because simplerdb is in memory db.  
   # Video.all.each{|v| v.destroy}
   @server.shutdown
   @thread.join
  end
end

describe "using MySQL" do
  before() do
    # Not required if the detail is specified at database.yml
    # DataMapper.setup(:test,{
    #   :adapter => 'mysql',
    #   :database => 'panda_test',
    #   :username => 'root',
    #   :host =>  'localhost',
    #   :encoding =>  'utf8'
    # })
  end

  it "should return videos at processing or queued" do
    pending
    mock_video(:id => UUID.new, :status => 'queued').save
    mock_video(:id => UUID.new, :status => 'processing').save
    mock_video(:id => UUID.new, :status => 'original').save

    queued_encodings = Video.queued_encodings
    queued_encodings.should have(2).videos
    queued_encodings.each{|e| e.status.should_not == 'original'}
  end

  after() do
   Video.all.each{|v| v.destroy}
  end
end
