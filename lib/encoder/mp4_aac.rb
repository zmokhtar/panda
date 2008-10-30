class Encoder::MP4AAC < Encoder::FFMPEG
  
  private
  
  def encode_video
    Merb.logger.info "Encoding with encode_mp4_aac_flash"
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -acodec libfaac -ar 48000 -ab $audio_bitrate$k -ac 2 -b $video_bitrate_in_bits$ -vcodec libx264 -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -coder 1 -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -me hex -subq 5 -me_range 16 -g 250 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 $resolution_and_padding$ -r 24 -threads 4 -y $output_file$"
    transcoder.execute(recipe, recipe_options(parent_video.tmp_filepath, @encoding.tmp_filepath))
  end
  
end