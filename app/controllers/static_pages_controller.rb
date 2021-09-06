class StaticPagesController < ApplicationController

  def home
    if request.host.end_with?('welocally.at')
      @campaign_user = CampaignUser.new
      render 'campaign_users/index',  layout: 'campaign_users'
    elsif current_user
      redirect_to current_user.graetzl
    else
      @activity_sample = ActivitySample.new
    end
  end

  def robots
    render 'robots.text'
  end

end
