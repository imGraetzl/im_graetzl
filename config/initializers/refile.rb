require 'refile/s3'

if Rails.env.production?

  aws = {
    access_key_id: ENV['S3_ACCESS_KEY'],
    secret_access_key: ENV['S3_SECRET_ACCESS_KEY'],
    region: 'eu-central-1',
    bucket: ENV['S3_BUCKET'],
  }
  Refile.cache = Refile::S3.new(prefix: 'refile/cache', **aws)
  Refile.store = Refile::S3.new(prefix: 'refile/store', **aws)

end