CarrierWave.configure do |config|
  if Rails.env.production?
    config.enable_processing = true
    #config.root = ENV['OPENSHIFT_DATA_DIR']
    config.root = File.join(Rails.root, 'public/')
    config.cache_dir = config.root + 'uploads'
  elsif Rails.env.test?
    config.root = File.join(Rails.root, 'public/')
    config.store_dir = 'test_uploads'
    config.cache_dir = config.root + 'test_uploads'
  end
end