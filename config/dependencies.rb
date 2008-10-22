# dependencies are generated using a strict version, don't forget to edit the dependency versions when upgrading.
merb_gems_version = "0.9.10"
dm_gems_version   = "0.9.7"

# For more information about each component, please read http://wiki.merbivore.com/faqs/merb_components
dependency "merb-assets", merb_gems_version  
dependency "merb-helpers", merb_gems_version 
dependency "merb-mailer", merb_gems_version  
 
dependency "dm-core", dm_gems_version         

dependency 'uuid'
dependency 'amazon_sdb'
dependency 'activesupport'
dependency 'rvideo'
dependency 'dm-timestamps'

# Dependencies in lib - not autoloaded in time so require them explicitly
require 'simple_db'
require 'local_store'
