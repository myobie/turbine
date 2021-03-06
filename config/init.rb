# Go to http://wiki.merbivore.com/pages/init-rb

require 'config/dependencies.rb'

Merb.push_path(:lib, Merb.root / "lib")

use_orm :datamapper
use_test :bacon
use_template_engine :haml
 
Merb::Config.use do |c|
  c[:use_mutex] = false
  c[:session_store] = 'cookie'  # can also be 'memory', 'memcache', 'container', 'datamapper
  
  # cookie session store configuration
  c[:session_secret_key]  = '356cb598ec01869fc30117eb55a9fcca88b7c351'  # required for cookie session store
  c[:session_id_key] = '_turbine_session_id' # cookie session id key, defaults to "_session_id"
end
 
Merb::BootLoader.before_app_loads do
  # This will get executed after dependencies have been loaded but before your app's classes have loaded.
end
 
Merb::BootLoader.after_app_loads do
  # This will get executed after your app's classes have been loaded.
  PostType.preferred_order = [Video, Audio, Photo, Chat, Review, Link, Quote, Article]
end
