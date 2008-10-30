class Encoder::FFMPEG < Encoder::Base
  
  private
  
  def encode_video
    Merb.logger.info "Encoding with encode_unknown_format"
    transcoder = RVideo::Transcoder.new
    recipe = "ffmpeg -i $input_file$ -f $container$ -vcodec $video_codec$ -b $video_bitrate_in_bits$ -ar $audio_sample_rate$ -ab $audio_bitrate$k -acodec $audio_codec$ -r 24 $resolution_and_padding$ -y $output_file$"
    Merb.logger.info "Unknown encoding format given but trying to encode anyway."
    transcoder.execute(recipe, recipe_options(parent_video.tmp_filepath, @encoding.tmp_filepath))
  end
  
  def recipe_options(input_file, output_file)
    {
      :input_file => input_file,
      :output_file => output_file,
      :container => @encoding.container, 
      :video_codec => @encoding.video_codec,
      :video_bitrate_in_bits => @encoding.video_bitrate_in_bits.to_s, 
      :fps => @encoding.fps,
      :audio_codec => @encoding.audio_codec.to_s, 
      :audio_bitrate => @encoding.audio_bitrate.to_s, 
      :audio_bitrate_in_bits => @encoding.audio_bitrate_in_bits.to_s, 
      :audio_sample_rate => @encoding.audio_sample_rate.to_s, 
      :resolution => @encoding.resolution,
      :resolution_and_padding => ffmpeg_resolution_and_padding_no_cropping
    }
  end
  
  def ffmpeg_resolution_and_padding_no_cropping
    # Calculate resolution and any padding
    in_w = parent_video.width.to_f
    in_h = parent_video.height.to_f
    out_w = @encoding.width.to_f
    out_h = @encoding.height.to_f

    begin
      aspect = in_w / in_h
      aspect_inv = in_h / in_w
    rescue
      Merb.logger.error "Couldn't do w/h to caculate aspect. Just using the output resolution now."
      return %(-s #{@encoding.width}x#{@encoding.height} )
    end

    height = (out_w / aspect.to_f).to_i
    height -= 1 if height % 2 == 1

    opts_string = %(-s #{@encoding.width}x#{height} )

    # Keep the video's original width if the height
    if height > out_h
      width = (out_h / aspect_inv.to_f).to_i
      width -= 1 if width % 2 == 1

      opts_string = %(-s #{width}x#{self.height} )
      @encoding.width = width
      @encoding.save
    # Otherwise letterbox it
    elsif height < out_h
      pad = ((out_h - height.to_f) / 2.0).to_i
      pad -= 1 if pad % 2 == 1
      opts_string += %(-padtop #{pad} -padbottom #{pad})
    end

    return opts_string
  end
  
end