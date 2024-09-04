class WidgetsController < ApplicationController

  before_action :set_headers

  # Crowdfunding Project Widget
  def crowdfunding
    @crowd_campaign = CrowdCampaign.find(params[:id])

    # Improve - Check Fingerprint (Staging)
    # Add Error Handling ...
    if Rails.env.development?
      @image_url = "http://#{Rails.application.config.welocally_host}:#{request.port}#{@crowd_campaign.cover_photo_url}"
    else
      @image_url = @crowd_campaign.cover_photo_url(host: "https://#{ENV['UPLOADS_BUCKET']}.s3.eu-central-1.amazonaws.com")
    end

    respond_to do |format|
      format.json 
      render "widgets/crowd_campaign.json"
    end
  end

  private

  def set_headers
    response.headers['X-Frame-Options'] = 'ALLOWALL'
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

end
