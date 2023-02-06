require 'aws-sdk-s3'

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.welocally.at"
# pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'
# store on S3 using aws-sdk
SitemapGenerator::Sitemap.sitemaps_path = "sitemaps/welocally"
# Use Localhost (FileAdapter) or AWS Upload

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(ENV['UPLOADS_BUCKET'],
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  aws_region: ENV['AWS_REGION']
)

#SitemapGenerator::Sitemap.adapter = SitemapGenerator::FileAdapter.new
# TASK - setup on heroku:
#rake sitemap:refresh:no_ping CONFIG_FILE="config/sitemap_welocally_home.rb"

SitemapGenerator::Sitemap.create do

  add root_path, changefreq: 'always', priority: 1
  add andocken_path, changefreq: 'always', priority: 1

  # Info Pages
  add info_path, changefreq: 'monthly', priority: 1
  add info_ueber_uns_path, changefreq: 'weekly', priority: 0.9
  add info_presse_path, changefreq: 'weekly', priority: 0.9
  add info_meilensteine_path, changefreq: 'weekly', priority: 0.8
  add info_agb_path, changefreq: 'never', priority: 0.2
  add info_datenschutz_path, changefreq: 'never', priority: 0.2
  add info_impressum_path, changefreq: 'never', priority: 0.2

end
