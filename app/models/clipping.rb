# Clipping for a given encoding or parent video.
# 
class Clipping
  
  include LocalStore
  
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
  def tmp_url(size, position)
    public_url(@video.filename, size, position, '.jpg')
  end
  
  # Position (as percentage) within the video
  def position
    parent_video.thumbnail_position || 50
  end
  
  def capture(position_chosen = position())
    raise RuntimeError, "Video must exist to call capture" unless File.exists?(@video.tmp_filepath)
        
    t = RVideo::Inspector.new(:file => @video.tmp_filepath)
    t.capture_frame("#{position_chosen}%", tmp_path(:screenshot, position_chosen))
  end
  
  def resize(position_chosen = position())
    constrain_to_height = Panda::Config[:thumbnail_height_constrain].to_f
    
    height = constrain_to_height
    width = (@video.width.to_f/@video.height.to_f) * height
    
    GDResize.new.resize \
      tmp_path(:screenshot, position_chosen),
      tmp_path(:thumbnail, position_chosen),
      [width.to_i, height.to_i]
  end
  
  def upload_to_store
    Store.set \
      filename(:screenshot), 
      tmp_path(:screenshot, self.position)
    Store.set \
      filename(:thumbnail), 
      tmp_path(:thumbnail, self.position)
  end
  
  private
  
  def parent_video
    @video.parent_video
  end
  
  def tmp_path(size, position)
    public_filepath(@video.filename, size, position, '.jpg')
  end
  
end
