class MarketingMailer < ApplicationMailer

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

  def energieteiler_meeting_invite(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "energieteiler-meeting-invite")

    mail(
      subject: "Sorry, Infotreffen 'Energiegemeinschaften' ist am Mittwoch, nicht Montag...",
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
