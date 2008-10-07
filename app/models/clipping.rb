# Clipping for a given encoding.
# 
# Does it make sense for a parent video?
# 
class Clipping
  
  def initialize(video)
    @video = video
  end
  
  def filename(size)
    if size == :thumbnail
      @video.filename + "_thumb.jpg"
    elsif size == :screenshot
      @video.filename + ".jpg"
    else
      raise "Invalid size: chosse :thumbnail or :screenshot"
    end
  end
  
  # URL once it has been uploaded
  def url(size)
    Store.url(self.filename(size.to_sym))
  end
  
  # URL on the panda instance (before it has been uploaded)
  def tmp_url(size)
    Panda::Config[:public_tmp_url] + args.map { |e| e.to_s }.join('_')
  end
  
  # Position (as percentage) within the video
  def position
    parent_video.thumbnail_position || 50
  end
  
  def capture(position_chosen = position())
    raise RuntimeError, "Video must exist to call capture" unless File.exists?(@video.tmp_filepath)
        
    t = RVideo::Inspector.new(:file => @video.tmp_filepath)
    t.capture_frame("#{position_chosen}%", public_filepath(@video.filename, :screenshot, position_chosen))
  end
  
  def resize(position_chosen = position())
    constrain_to_height = Panda::Config[:thumbnail_height_constrain].to_f
    
    height = constrain_to_height
    width = (@video.width.to_f/@video.height.to_f) * height
    
    GDResize.new.resize \
      public_filepath(@video.filename, :screenshot, position_chosen),
      public_filepath(@video.filename, :thumbnail, position_chosen),
      [width.to_i, height.to_i]
  end
  
  def upload_to_store
    Store.set \
      filename(:screenshot), 
      public_filepath(@video.filename, :screenshot, position)
    Store.set \
      filename(:thumbnail), 
      public_filepath(@video.filename, :thumbnail, position)
  end
  
  private
  
  def parent_video
    @video.parent_video
  end
  
  # This path can be accessible from the web
  def public_filepath(*args)
    Panda::Config[:public_tmp_path] / args.map { |e| e.to_s }.join('_')
  end
  
end
