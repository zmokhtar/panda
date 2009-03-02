Merb.logger.info("Loaded NOTIFIER Environment...")
Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:log_level] = :error
  
  c[:log_file]  = Merb.root / "log" / "notifier.log"
  # or redirect logger using IO handle
  # c[:log_stream] = STDOUT
}
