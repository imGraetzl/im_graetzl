class WidgetsController < ApplicationController

  before_action :set_headers

  # Crowdfunding Project Widget
  def crowdfunding
    @crowd_campaign = CrowdCampaign.find(params[:id])

    # Improve - Check Fingerprint (Staging)
    # Add Error Handling ...
    if Rails.env.development?
      @image_url = "http://#{Rails.application.config.welocally_host}:#{request.port}#{@crowd_campaign.cover_photo_url(:header, :large)}"
    else
      @image_url = @crowd_campaign.cover_photo_url(:header, :large, host: "https://#{ENV['UPLOADS_BUCKET']}.s3.eu-central-1.amazonaws.com")
    end

    render formats: [:json]
  end

  private

  def set_headers
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

end
