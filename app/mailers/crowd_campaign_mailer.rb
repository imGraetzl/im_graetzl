class CrowdCampaignMailer < ApplicationMailer

  def draft(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-draft")
    mail(
      subject: "Brauchst du Hilfe bei deiner Crowdfundig Kampagne? ...",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def pending(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-pending")
    mail(
      subject: "Deine Kampagne wird nun geprüft. Wichtige nächste Schritte ...",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def approved(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-approved")
    mail(
      subject: "Gratuliere, deine Kampagne wurde freigegeben. Wichtige nächste Schritte vor dem Start ...",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def funding_started(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-funding")
    mail(
      subject: "Yeah, deine Crowdfunding Kampagne ist nun aktiv. Auf was es jetzt ankommt!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def goal_1_reached(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-funding-1-successful")
    mail(
      subject: "Gratuliere, du hast dein Fundingziel erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def goal_2_reached(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-funding-2-successful")
    mail(
      subject: "Gratuliere, du hast dein Fundingziel erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def completed_successful(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-completed-successful")
    mail(
      subject: "Gratuliere, du hast dein Fundingziel erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def completed_unsuccessful(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-completed-unsuccessful")
    mail(
      subject: "Gratuliere, du hast dein Fundingziel erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

end
