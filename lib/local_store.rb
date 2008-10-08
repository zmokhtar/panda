module LocalStore
  
  def self.ensure_directories_exist
    private_dir = Panda::Config[:private_tmp_path]
    public_dir  = Panda::Config[:public_tmp_path]
    
    FileUtils.mkdir_p(private_dir)
    FileUtils.mkdir_p(public_dir)
  end
  
  private
  
  # This path can be accessible from the web
  def public_filepath(*args)
    Panda::Config[:public_tmp_path] / args.map { |e| e.to_s }.join('_')
  end
  
  # URL on the panda instance (before it has been uploaded)
  def public_url(*args)
    Panda::Config[:public_tmp_url] + '/' + args.map { |e| e.to_s }.join('_')
  end
  
end
