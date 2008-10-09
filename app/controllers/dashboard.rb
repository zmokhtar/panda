class Dashboard < Application
  before :require_login
  
  def index
    @queued_encodings = Video.queued_encodings
    render
  end
end