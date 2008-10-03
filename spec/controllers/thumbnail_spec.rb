require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Thumbnail, "index action" do
  before(:each) do
    dispatch_to(Thumbnail, :index)
  end
end