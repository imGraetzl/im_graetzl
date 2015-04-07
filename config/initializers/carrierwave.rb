CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage = :file
    config.enable_processing = true
    config.root = ENV['OPENSHIFT_DATA_DIR']
    config.cache_dir = config.root + 'uploads'
  end    
end