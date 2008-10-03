class Thumbnail < Application

  before :require_login, :only => [:edit, :update]
  before :get_video
  
  # This will be inside an iframe.
  # 
  def new
    @percentages = @video.thumbnail_percentages
    
    render :layout => :uploader
  end
  
  # This will be inside an iframe.
  # 
  # We've come from the upload form and the thumbnail will be generated when 
  # the video is encoded
  # 
  def create
    @video.cleanup_thumbnail_selection
    @video.thumbnail_position = params[:percentage]
    @video.save
    @video.add_to_queue
    
    redirect @video.upload_redirect_url
  end
  
  def edit
    @percentages = @video.thumbnail_percentages
    
    @video.fetch_from_s3
    @video.generate_thumbnail_selection
    render
  end
  
  # HQ
  # 
  # The video is already encoded and we're changing its thumbnail
  # 
  def update
    @video.cleanup_thumbnail_selection
    @video.thumbnail_position = params[:percentage]
    @video.save
    # @video.add_to_queue
    
    @video.successfull_encodings.each do | video |
      video.fetch_from_s3
      video.capture_thumbnail_and_upload_to_s3
      FileUtils.rm video.tmp_filepath
    end
    
    redirect "/videos/#{@video.key}"
  end
  
  private
  
  def get_video
    # Throws Amazon::SDB::RecordNotFoundError if video cannot be found
    @video = Video.find(params[:video_id])
  end
  
end
