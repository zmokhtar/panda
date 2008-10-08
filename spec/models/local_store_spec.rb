require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe LocalStore do
  class Dummy
    include LocalStore
  end
  
  before :each do
    @dummy = Dummy.new
  end
  
  it "private_filepath should concatenate args to private path" do
    Panda::Config.should_receive(:[]).with(:private_tmp_path).
      and_return '/path'
    @dummy.send(:private_filepath, 'foo', 'bar').should == '/path/foo_bar'
  end
  
  it "public_filepath should concatenate args to public path" do
    Panda::Config.should_receive(:[]).with(:public_tmp_path).
      and_return '/public'
    @dummy.send(:public_filepath, 'foo', 'bar').should == '/public/foo_bar'
  end
  
  it "public_url should concatenate args to public url" do
    Panda::Config.should_receive(:[]).with(:public_tmp_url).
      and_return 'http://example.com/tmp'
    @dummy.send(:public_url, 'foo', 'bar').
      should == 'http://example.com/tmp/foo_bar'
  end
end
