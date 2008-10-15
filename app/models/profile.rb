class Profile
  include DataMapper::Resource
  
  property :id, String, :key => true
  property :title, String
  property :player, String
  property :container, String
  property :width, Integer
  property :height, Integer
  property :video_codec, String
  property :video_bitrate, String
  property :fps, String
  property :audio_codec,String 
  property :audio_bitrate, String
  property :audio_sample_rate, String
  property :position, Integer
  property :updated_at, DateTime
  property :created_at, DateTime
  
  def self.warn_if_no_encodings
    if Profile.all.empty?
      Merb.logger.info "PANDA CONFIG ERROR: There are no encoding profiles. You probably forgot to define them. Please see the getting started guide."
    end
  end
end
