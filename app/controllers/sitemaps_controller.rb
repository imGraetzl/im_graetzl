class SitemapsController < ApplicationController

  def sitemap

    redirect_to "https://s3.eu-central-1.amazonaws.com/im-graetzl-production/sitemaps/#{current_region.id}/sitemap.xml.gz"

  end

end
