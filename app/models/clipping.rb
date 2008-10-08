# Clipping for a given encoding or parent video.
# 
class Clipping
  
  include LocalStore
  
  def initialize(video, position = nil)
    @video = video
    @_position = position
  end
  
  def filename(size, opts = {})
    raise "Invalid size: choose :thumbnail or :screenshot" unless [:thumbnail, :screenshot].include?(size)
    
    name = [@video.filename]
    name << position unless opts[:default]
    name << 'thumb' if size == :thumbnail
    
    return name.join('_') + '.jpg'
  end
  
  # URL once it has been uploaded
  def url(size)
    Store.url(self.filename(size.to_sym, :default => true))
  end
  
  # URL on the panda instance (before it has been uploaded)
  def tmp_url(size)
    public_url(@video.filename, size, position, '.jpg')
  end
  
  def capture
    raise RuntimeError, "Video must exist to call capture" unless File.exists?(@video.tmp_filepath)
        
    t = RVideo::Inspector.new(:file => @video.tmp_filepath)
    t.capture_frame("#{position}%", tmp_path(:screenshot))
  end
  
  def resize
    constrain_to_height = Panda::Config[:thumbnail_height_constrain].to_f
    
    height = constrain_to_height
    width = (@video.width.to_f/@video.height.to_f) * height
    
    GDResize.new.resize \
      tmp_path(:screenshot),
      tmp_path(:thumbnail),
      [width.to_i, height.to_i]
  end
  
  # Uploads this clipping to the default clipping locations on store (default 
  # url does not contain position)
  def set_as_default
    Store.set \
      filename(:screenshot, :default => true), 
      tmp_path(:screenshot)
    Store.set \
      filename(:thumbnail, :default => true), 
      tmp_path(:thumbnail)
  end
  
  # Upload this clipping to store (with position info in the url)
  def upload_to_store
    Store.set \
      filename(:screenshot),
      tmp_path(:screenshot)
    Store.set \
      filename(:thumbnail), 
      tmp_path(:thumbnail)
  end
  
  def changeable?
    Panda::Config[:choose_thumbnail] != false
  end
  
  private
  
  def original_video
    (@video.status == 'original') ? @video : @video.parent_video
  end
  
  def tmp_path(size)
    public_filepath(@video.filename, size, position, '.jpg')
  end
  
  def position
    @_position || original_video.thumbnail_position || 50
  end
  
end
