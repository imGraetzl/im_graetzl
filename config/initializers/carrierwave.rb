CarrierWave.configure do |config|

  if Rails.env.production?

    config.enable_processing = true
    #config.root = ENV['OPENSHIFT_DATA_DIR']
    #config.root = File.join(Rails.root, 'public/')
    #config.cache_dir = config.root + 'uploads'

    config.storage = :aws
    #config.fog_provider = 'fog/aws'
    config.aws_credentials = {
      access_key_id: ENV.fetch('S3_ACCESS_KEY'),
      secret_access_key: ENV.fetch('S3_SECRET_ACCESS_KEY'),
      region: 'eu-central-1'
    }
    config.aws_bucket =  ENV.fetch('S3_BUCKET'),
    config.aws_acl = :'public-read'
    config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365
    #config.fog_attributes = { 'Cache-Control' => "max-age=#{365.day.to_i}" } # optional, defaults to {}

  else
    config.storage = :file

    if Rails.env.test?
      config.root = File.join(Rails.root, 'public/')
      config.store_dir = 'test_uploads'
      config.cache_dir = config.root + 'test_uploads'
    end
  end
end