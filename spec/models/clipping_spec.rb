require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Clipping do
  
  before :each do
    @parent_video = mock(Video)
    @video = mock(Video, :filename => "foo", :parent_video => @parent_video, :width => 10, :height => 20)
    @clipping = Clipping.new(@video)
  end
  
  describe "initialize" do
    it "should take video and store the reference" do
      clipping = Clipping.new(@video)
      clipping.instance_variable_get(:@video).should == @video
    end
  end
  
  describe "filename" do
    it "should be [video_filename]_thumb.jpg for :thumbnail" do
      @clipping.filename(:thumbnail).should == @video.filename + '_thumb.jpg'
    end
    
    it "should be [video_filename].jpg for :screenshot" do
      @clipping.filename(:screenshot).should == @video.filename + '.jpg'
    end
    
    it "should raise error for other sizes" do
      lambda {
        @clipping.filename(:something_else)
      }.should raise_error
    end
  end
  
  describe "url" do
    it "should fetch url info from store" do
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
  
  describe "tmp_url" do
    it "should use public_url to generate url" do
      @clipping.should_receive(:public_url).with(@video.filename, :thumbnail, 40, '.jpg')
      @clipping.tmp_url(:thumbnail, 40)
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
    
    it "should store" do
      Store.should_receive(:set).twice
      @clipping.upload_to_store
    end
  end
  
  describe "capture" do
    before :each do
      @video_file = 'video'
      @video.stub!(:tmp_filepath).and_return(@video_file)
      @clipping_file = 'foo'
      @clipping.stub!(:public_filepath).and_return(@clipping_file)
      @clipping.stub!(:position)
      @inspector = mock(RVideo::Inspector)
      RVideo::Inspector.stub!(:new).with(:file => @video_file).and_return(@inspector)
      File.stub!(:exists?).and_return(true)
    end
    
    it "should raise exception if the encoding is not available locally" do
      File.should_receive(:exists?).with(@video_file).and_return(false)
      
      lambda {
        @clipping.capture
      }.should raise_error
    end
    
    it "should optionally take a parameter for the position" do
      chosen_position = 20
      
      @clipping.should_not_receive(:position)
      @inspector.should_receive(:capture_frame).with("#{chosen_position}%", @clipping_file)
      
      @clipping.capture(chosen_position)
    end
    
    it "should capture clipping from encoding and save to public tmp dir" do
      @video.should_receive(:tmp_filepath).twice.and_return(@video_file)
      @clipping.should_receive(:public_filepath).and_return(@clipping_file)
      default_position = 80
      @clipping.should_receive(:position).and_return(default_position)
      
      RVideo::Inspector.should_receive(:new).with(:file => @video_file).and_return(@inspector)
      @inspector.should_receive(:capture_frame).with("#{default_position}%", @clipping_file)
      
      @clipping.capture
    end
    
    it "should resize with position" do
      gd = mock(GDResize)
      gd.should_receive(:resize)
      GDResize.should_receive(:new).and_return(gd)
      
      @clipping.resize
    end
  end
  
end
