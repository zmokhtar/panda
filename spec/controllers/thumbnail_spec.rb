require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Thumbnail do
  
  before :each do
    @video = mock(Video)
    @video.stub!(:filename).and_return('')
    @video.stub!(:key).and_return('123')
    Video.stub!(:find).with(@video.filename).and_return(@video)
  end

  describe "edit action" do
    it "should provide video thumbnails with various positions " do
      @video.should_receive(:thumbnail_percentages)
      dispatch_to(Thumbnail, :edit, :video_id => @video.filename ) do | c |
        c.stub!(:render)
        c.stub!(:require_login).and_return(true)
      end.should be_successful
    end
  end
  
  describe "update action" do
    before(:each) do
      @video.stub!(:thumbnail_position=)
      @video.stub!(:save)
      
      @clipping = mock(Clipping)
      @clipping.stub!(:upload_to_store)
      @encoding = mock(Video)
      @encoding.stub!(:clipping).and_return(@clipping)
      @video.stub!(:successful_encodings).and_return([@encoding])
    end
    
    it "should update thumbnail position" do
      @video.should_receive(:thumbnail_position=)
      @video.should_receive(:save)
      
      dispatch
    end

    it "should upload clipping to store" do
      @clipping.should_receive(:upload_to_store)
      
      dispatch
    end
    
    it "should redirect to video page" do
      dispatch.should redirect_to(url(:video, @video.key))
    end
    
    def dispatch
      dispatch_to(Thumbnail, 
                  :update, 
                  :video_id => @video.filename, 
                  :percentage => 50 ) do |c|
        c.stub!(:render)
        c.stub!(:require_login).and_return(true)
      end
    end
  end
  
end
