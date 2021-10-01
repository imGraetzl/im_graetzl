class CampaignUsersController < ApplicationController
  layout 'campaign_users'

  def index
    @campaign_user = CampaignUser.new
  end

  def muehlviertel
    @campaign_user = CampaignUser.new
  end

  def kaernten
    @campaign_user = CampaignUser.new
  end

  def create
    @campaign_user = CampaignUser.new(campaign_user_params)
    if @campaign_user.save
      redirect_to params[:redirect_path]
      flash[:notice] = "Vielen lieben Dank für deine Voranmeldung! Wir melden uns bei dir, sobald es los geht."
    else
      render params[:campaign] || 'index'
    end
  end

  private

  def campaign_user_params
    params.require(:campaign_user).permit(
      :campaign_title,
      :first_name,
      :last_name,
      :email,
      :website,
      :zip,
      :city
    )
  end

end
