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

  def hot_august_room_pusher(room_offer)
    @room_offer = room_offer
    @user = @room_offer.user
    @region = @room_offer.region

    headers("X-MC-Tags" => "hot-august-room-pusher")

    mail(
      subject: "Dein Raum braucht mehr Aufmerksamkeit? Lass uns das pushen!",
      from: platform_email("mirjam", "Mirjam Mieschendahl"),
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
