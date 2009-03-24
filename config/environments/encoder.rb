Merb.logger.info("Loaded ENCODER Environment...")
Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:log_auto_flush ] = true
  c[:log_level] = :warn
  
  c[:log_file]  = Merb.root / "log" / "encoder.log"
  # or redirect logger using IO handle
  # c[:log_stream] = STDOUT
}
