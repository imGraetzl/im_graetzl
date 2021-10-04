class SitemapsController < ApplicationController

  def sitemap

    if current_region.nil?
      redirect_to "https://s3.eu-central-1.amazonaws.com/#{ENV['UPLOADS_BUCKET']}/sitemaps/welocally/sitemap.xml.gz"
    else
      redirect_to "https://s3.eu-central-1.amazonaws.com/#{ENV['UPLOADS_BUCKET']}/sitemaps/#{current_region.id}/sitemap.xml.gz"
    end

  end

end
