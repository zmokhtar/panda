class Encoder::Base
  
  def initialize(encoding)
    @encoding = encoding
  end
  
  def encode
    encode_video
  end
  
  private
  
  def parent_video
    @encoding.parent_video
  end
  
  def encode_video
    raise NotImplemented, "Method implemented in specific encoders"
  end
  
end
