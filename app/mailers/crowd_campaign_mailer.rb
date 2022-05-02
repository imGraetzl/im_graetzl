class CrowdCampaignMailer < ApplicationMailer

  def draft(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-draft")
    mail(
      subject: "Wie geht es deinem Vorhaben?",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def pending(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-pending")
    mail(
      subject: "Deine Kampagne wird geprüft plus wichtige Infos",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def approved(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-approved")
    mail(
      subject: "Deine Kampagne ist freigegeben, die nächsten Schritte",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def funding_started(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-funding")
    mail(
      subject: "Es geht los, deine Kampagne ist online",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def keep_up(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-keep-up")
    mail(
      subject: "Jetzt dranbleiben",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def goal_1_reached(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-goal-1-reached")
    mail(
      subject: "Hurra, das erste Fundingziel ist erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def goal_2_reached(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-goal-2-reached")
    mail(
      subject: "Es ist wieder etwas Schönes passiert, das zweite Fundingziel ist erreicht!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def completed_successful(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-completed-successful")
    mail(
      subject: "Deine Kampagne ist erfolgreich beendet! Dein Vorhaben kann bald starten!",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def completed_unsuccessful(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-campaign-completed-unsuccessful")
    mail(
      subject: "Diesmal hat es leider nicht geklappt",
      from: platform_email('no-reply'),
      to: @crowd_campaign.user.email,
    )
  end

  def crowd_pledge_confirmation(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-confirmation")
    mail(
      subject: "Unterstützungsbestätigung für #{@crowd_campaign.title}",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_completed_successful(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-completed-successful")
    mail(
      subject: "Unterstütztes Projekt ist erfolgreich: #{@crowd_campaign.title}",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_payment_failed(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-payment-failed")
    mail(
      subject: "Deine Crowdfunding Unterstützung ist leider fehlgeschlagen, bitte ändere deine Zahlungsmethode.",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

end
