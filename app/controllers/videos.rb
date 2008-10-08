class Videos < Application
  before :require_login, :only => [:index, :show, :destroy, :new, :create, :add_to_queue]
  before :set_video, :only => [:show, :destroy, :add_to_queue]
  before :set_video_with_nice_errors, :only => [:form, :done, :state]

  def index
    provides :html, :xml, :yaml
    
    @videos = Video.all
    
    display @videos
  end

  def show
    provides :html, :xml, :yaml
    
    case content_type
    when :html
      # TODO: use proper auth method
      @user = User.find(session[:user_key]) if session[:user_key]
      if @user
        if @video.status == "original"
          render :show_parent
        else
          render :show_encoding
        end
      else
        redirect("/login")
      end
    when :xml
      @video.show_response.to_simple_xml
    when :yaml
      @video.show_response.to_yaml
    end
  end
  
  # Use: HQ
  # Only used in the admin side to post to create and then forward to the form 
  # where the video is uploaded
  def new
    render :layout => :simple
  end
  
  # Use: HQ
  def destroy
    @video.obliterate!
    redirect "/videos"
  end

  # Use: HQ, API
  def create
    provides :html, :xml, :yaml
    
    @video = Video.create_empty
    Merb.logger.info "#{@video.key}: Created video"
    
    case content_type
    when :html
      redirect url(:form_video, @video.key)
    when :xml
      headers.merge!({'Location'=> "/videos/#{@video.key}"})
      @video.create_response.to_simple_xml
    when :yaml
      headers.merge!({'Location'=> "/videos/#{@video.key}"})
      @video.create_response.to_yaml
    end
  end
  
  # Use: HQ, API, iframe upload
  def form
    render :layout => :uploader
  end
  
  # Use: HQ, http/iframe upload
  def upload
    begin
      raise Video::NoFileSubmitted if !params[:file] || params[:file].blank?
      @video = Video.find(params[:id])
      @video.filename = @video.key + File.extname(params[:file][:filename])
      FileUtils.mv params[:file][:tempfile].path, @video.tmp_filepath
      @video.original_filename = params[:file][:filename].split("\\\\").last # Split out any directory path Windows adds in
      # @video.process
      @video.valid?
      @video.read_metadata
      @video.upload_to_store
      
      # Generate thumbnails before we save so the encoder doesn't get there first and delete our file!
      if Panda::Config[:choose_thumbnail]
        @video.generate_thumbnail_selection
        @video.upload_thumbnail_selection
      else
        @video.add_to_queue
      end
      
      @video.status = "original"
      @video.save
      FileUtils.rm @video.tmp_filepath
    rescue Amazon::SDB::RecordNotFoundError # No empty video object exists
      self.status = 404
      render_error($!.to_s.gsub(/Amazon::SDB::/,""))
    rescue Video::NotValid # Video object is not empty. It's likely a video has already been uploaded for this object.
      self.status = 404
      render_error($!.to_s.gsub(/Video::/,""))
    rescue Video::VideoError
      self.status = 500
      render_error($!.to_s.gsub(/Video::/,""))
    rescue => e
      self.status = 500
      render_error("InternalServerError", e) # TODO: Use this generic error in production
    else
      case content_type
      when :html  
        url = Panda::Config[:choose_thumbnail] ? "/videos/#{@video.key}/thumbnail/new?iframe=true" : @video.upload_redirect_url
        
        # Special internal Panda case: textarea hack to get around the fact that the form is submitted with a hidden iframe and thus the response is rendered in the iframe
        if params[:iframe] == "true"
          "<textarea>" + {:location => url}.to_json + "</textarea>"
        else
          redirect url
        end
      end
    end
  end
  
  # Default upload_redirect_url (set in panda_init.rb) goes here.
  def done
    render :layout => :uploader
  end
  
  # TODO: Why do we need this method?
  def add_to_queue
    @video.add_to_queue
    redirect "/videos/#{@video.key}"
  end
  
private

  def render_error(msg, exception = nil)
    Merb.logger.error "#{params[:id]}: (500 returned to client) #{msg}" + (exception ? "#{exception}\n#{exception.backtrace.join("\n")}" : '')

    case content_type
    when :html
      if params[:iframe] == "true"
        "<textarea>" + {:error => msg}.to_json + "</textarea>"
      else
        @exception = msg
        render(:template => "exceptions/video_exception", :layout => false) # TODO: Why is :action setting 404 instead of 500?!?!
      end
    when :xml
      {:error => msg}.to_simple_xml
    when :yaml
      {:error => msg}.to_yaml
    end
  end
  
  def set_video
    # Throws Amazon::SDB::RecordNotFoundError if video cannot be found
    @video = Video.find(params[:id])
  end
  
  def set_video_with_nice_errors
    begin
      @video = Video.find(params[:id])
    rescue Amazon::SDB::RecordNotFoundError
      self.status = 404
      throw :halt, render_error($!.to_s.gsub(/Amazon::SDB::/,""))
    end
  end
end
