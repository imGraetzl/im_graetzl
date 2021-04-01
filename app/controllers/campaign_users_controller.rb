class CampaignUsersController < ApplicationController

  def muehlviertel
    @campaign_user = CampaignUser.new
  end

  def kaernten
    @campaign_user = CampaignUser.new
  end

  def create

    @campaign_user = CampaignUser.new(campaign_user_params)

    campaign = params[:campaign_redirect].parameterize.underscore.to_sym

    if @campaign_user.save
      redirect_to campaign
      flash[:error] = "Vielen lieben Dank, du bist nun eingetragen! Wir melden uns in Kürze.."
    else
      render campaign
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
