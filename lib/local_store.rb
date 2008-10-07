module LocalStore
  
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
