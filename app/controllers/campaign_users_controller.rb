class CampaignUsersController < ApplicationController

  def index
    @campaign_user = CampaignUser.new
    render layout: 'campaign_users'
  end

  def muehlviertel
    @campaign_user = CampaignUser.new
    render layout: 'campaign_users'
  end

  def kaernten
    @campaign_user = CampaignUser.new
    render layout: 'campaign_users'
  end

  def create

    @campaign_user = CampaignUser.new(campaign_user_params)

    campaign = params[:campaign_user][:campaign_title].parameterize.underscore.to_sym if params[:campaign_user][:campaign_title].present?

    if @campaign_user.save
      redirect_to params[:redirect_path]
      flash[:error] = "Vielen lieben Dank für deine Voranmeldung! In wenigen Wochen gehts los ..."
    else
      campaign ? (render campaign) : (render 'index')
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
