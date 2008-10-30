class Encoder::FlvFlash < Encoder::FFMPEG
  
  private
  
  def encode_video
    Merb.logger.info "Encoding with encode_flv_flash"
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -ar 22050 -ab $audio_bitrate$k -f flv -b $video_bitrate_in_bits$ -r 24 $resolution_and_padding$ -y $output_file$"
    recipe += "\nflvtool2 -U $output_file$"
    transcoder.execute(recipe, recipe_options(parent_video.tmp_filepath, @encoding.tmp_filepath))
  end
  
end