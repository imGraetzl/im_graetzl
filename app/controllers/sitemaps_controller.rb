class SitemapsController < ApplicationController
  def sitemap
    if current_region.nil?
      redirect_to "https://s3.eu-central-1.amazonaws.com/#{ENV['UPLOADS_BUCKET']}/sitemaps/welocally/sitemap.xml.gz", allow_other_host: true
    else
      redirect_to "https://s3.eu-central-1.amazonaws.com/#{ENV['UPLOADS_BUCKET']}/sitemaps/#{current_region.id}/sitemap.xml.gz", allow_other_host: true
    end
  end
end
