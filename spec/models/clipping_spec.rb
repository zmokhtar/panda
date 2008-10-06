require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Clipping do
  
  before :each do
    @parent_video = mock(Video)
    @video = mock(Video, :filename => "foo", :parent_video => @parent_video)
    @clipping = Clipping.new(@video)
  end
  
  describe "initialize" do
    it "should take video" do
      Clipping.new(@video).should be_kind_of(Clipping)
    end
  end
  
  describe "file locations" do
    describe "filename" do
      it "should be [video_filename]_thumb.jpg for :thumbnail" do
        @clipping.filename(:thumbnail).should == @video.filename + '_thumb.jpg'
      end
      
      it "should be [video_filename].jpg for :screenshot" do
        @clipping.filename(:screenshot).should == @video.filename + '.jpg'
      end
      
      it "should raise error for invalid sizes" do
        lambda {
          @clipping.filename(:something_else)
        }.should raise_error
      end
    end
    
    describe "url" do
      it "should call store with the filename of size selected" do
        Store.should_receive(:url).with("#{@clipping.filename(:thumbnail)}").
          and_return('a')
        @clipping.url(:thumbnail).should == 'a'
      end
      
      it "should take a size option" do
        lambda {
          @clipping.url
        }.should raise_error
      end
      
      it "should raise error for invalid sizes" do
        lambda {
          @clipping.url(:something_else)
        }.should raise_error
      end
      
    end
    
    describe "position" do
      it "should read thumbnail_position from the parent video" do
        @parent_video.stub!(:thumbnail_position).and_return(99)
        @clipping.position.should == 99
      end
      
      it "should be 50 if thumbnail_position not set" do
        @parent_video.stub!(:thumbnail_position).and_return(nil)
        @clipping.position.should == 50
      end
    end
    
    describe "upload to store" do
      before :each do
        @parent_video.stub!(:thumbnail_position)
      end
      
      it "should call store" do
        Store.should_receive(:set).twice
        @clipping.upload_to_store
      end
    end
  end
  
end
