Merb.logger.info("Loaded TEST Environment...")
Merb::Config.use { |c|
  c[:testing] = true
  c[:exception_details] = true
  c[:log_auto_flush ] = true
  c[:log_level] = :fatal
  c[:log_file] = Merb.log_path / 'merb_test.log'
}
