CarrierWave.configure do |config|

  # let carrierwave fail nosily
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false

 if Rails.env.production?

    config.enable_processing = true
    #config.root = ENV['OPENSHIFT_DATA_DIR']
    #config.root = File.join(Rails.root, 'public/')
    #config.cache_dir = config.root + 'uploads'

    
    config.fog_provider = 'fog/aws'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['S3_ACCESS_KEY'],
      aws_secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
      region: 'eu-central-1'
    }
    config.fog_directory =  ENV['S3_BUCKET']
    #config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}

  else

    if Rails.env.test?
      config.root = File.join(Rails.root, 'public/')
      config.store_dir = 'test_uploads'
      config.cache_dir = config.root + 'test_uploads'
    end
  end
end