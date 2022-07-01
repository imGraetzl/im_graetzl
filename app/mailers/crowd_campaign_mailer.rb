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
      bcc: 'wir@imgraetzl.at',
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

  def invoice(crowd_campaign)
    @crowd_campaign = crowd_campaign
    @region = @crowd_campaign.region
    attachments["#{@crowd_campaign.invoice_number}.pdf"] = @crowd_campaign.invoice.get.body.read
    headers("X-MC-Tags" => "crowd-campaign-invoice")
    mail(
      subject: "Deine Kampagne ist nun zur Auszahlung bereit.",
      from: platform_email("no-reply"),
      to: @crowd_campaign.user.email,
    )
  end

  def crowd_pledge_authorized(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-authorized")
    mail(
      subject: "Unterstützungsbestätigung für #{@crowd_campaign.title}",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_goal_1_reached(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-goal-1-reached")
    mail(
      subject: "DANKE! '#{@crowd_campaign.title}' hat die erste Hürde gepackt! Mach mit beim Endspurt!",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_debited(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-debited")
    mail(
      subject: "Dein unterstütztes Projekt ist erfolgreich: #{@crowd_campaign.title}",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_failed(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-failed")
    mail(
      subject: "Dein unterstütztes Projekt ist erfolgreich - Fehler beim Einzug deiner Unterstützung, bitte überprüfe deine Zahlungsmethode.",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_failed_reminder(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-failed-reminder")
    mail(
      subject: "Erinnerung: Fehlerhafte Crowdfunding Unterstützung für '#{@crowd_campaign.title}'.",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_pledge_retried_debited(crowd_pledge)
    @crowd_pledge = crowd_pledge
    @crowd_campaign = @crowd_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-pledge-retried-debited")
    mail(
      subject: "Zahlungsbestätigung für deine Unterstützung.",
      from: platform_email('no-reply'),
      to: @crowd_pledge.email,
    )
  end

  def crowd_donation_pledge_info(crowd_donation_pledge)
    @crowd_donation_pledge = crowd_donation_pledge
    @crowd_campaign = @crowd_donation_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-donation-pledge-info")
    mail(
      subject: "Unterstützungsbestätigung für #{@crowd_campaign.title}",
      from: platform_email('no-reply'),
      to: @crowd_donation_pledge.email,
    )
  end

  def crowd_donation_pledge_success(crowd_donation_pledge)
    @crowd_donation_pledge = crowd_donation_pledge
    @crowd_campaign = @crowd_donation_pledge.crowd_campaign
    @region = @crowd_campaign.region
    headers("X-MC-Tags" => "crowd-donation-pledge-success")
    mail(
      subject: "Dein unterstütztes Projekt ist erfolgreich: #{@crowd_campaign.title}",
      from: platform_email('no-reply'),
      to: @crowd_donation_pledge.email,
    )
  end

  def message_to_user(campaign, user, subject, message)
    @crowd_campaign, @user, @message = campaign, user, message
    @region = @crowd_campaign.region
    @reply_email = @crowd_campaign.contact_email
    @sender_email = email_address_with_name("no-reply@#{@region.host_domain}", "#{@crowd_campaign.title} | über #{@region.host_domain_name}")
    headers(
      "X-MC-Tags" => "crowd-campaign-user-mail",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "crowd-campaign-user-mail",
    )
    mail(
      subject: "Crowdfunding Post für dich: #{subject}",
      to: email_address_with_name(user.email,user.full_name),
      from: @sender_email,
      reply_to: @reply_email,
    )
  end

end
