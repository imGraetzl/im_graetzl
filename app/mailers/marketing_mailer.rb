class MarketingMailer < ApplicationMailer

  def contact_list_entry(contact_list_entry)
    @contact_list_entry = contact_list_entry
    @region = contact_list_entry.region || Region.get('wien')

    headers("X-MC-Tags" => "contact-list-entry")

    mail(
      subject: "Interesse am Call zur Aktivierung von Leerstand – Nächste Schritte",
      from: platform_email("wir"),
      to: @contact_list_entry.email,
    )
  end

  def subscription_meeting_invite(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "subscription-meeting-invite")

    mail(
      subject: "Erinnerung: Einladung zum Jahrestreffen für imGrätzl Förder*innen am 23.11.",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  def toolteiler_sunset(tool_offer)
    @tool_offer = tool_offer
    @user = @tool_offer.user
    @region = @tool_offer.region

    headers("X-MC-Tags" => "toolteiler-sunset")

    mail(
      subject: "Der Geräteteiler-Bereich auf #{t("region.#{@region.id}.domain_short")} wird eingestellt",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  def agb_change_and_welocally(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "marketing-mail-welocally")

    mail(
      subject: "Wichtige Information: Neue Services & Änderungen der imGrätzl AGB",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  def agb_change_and_crowdfunding(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "marketing-mail-crowdfunding")

    mail(
      subject: "Wichtige Änderungen: Crowdfunding kommt -> Änderungen der imGrätzl AGB",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

end
