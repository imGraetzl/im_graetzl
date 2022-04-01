class CrowdCampaignMailer < ApplicationMailer

  def draft(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-draft")
    mail(
      subject: "Wie geht es deinem Vorhaben?",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def pending(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-pending")
    mail(
      subject: "Deine Kampagne wird geprüft plus wichtige Infos",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def approved(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-approved")
    mail(
      subject: "Deine Kampagne ist freigegeben, die nächsten Schritte",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def funding_started(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-funding")
    mail(
      subject: "Es geht los, deine Kampagne ist online",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def goal_1_reached(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-funding-1-successful")
    mail(
      subject: "Hurra, das erste Fundingziel ist erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def goal_2_reached(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-funding-2-successful")
    mail(
      subject: "Es ist wieder etwas Schönes passiert, das zweite Fundingziel ist erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def completed_successful(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-completed-successful")
    mail(
      subject: "Deine Kampagne ist erfolgreich beendet! Dein Vorhaben kann bald starten!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def completed_unsuccessful(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "notification-crowd-campaign-completed-unsuccessful")
    mail(
      subject: "Diesmal hat es leider nicht geklappt",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

end
