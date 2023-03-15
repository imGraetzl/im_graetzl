class AdminMailer < ApplicationMailer

  def daily_mail
    @region = Region.get('wien')

    mail(
      subject: "[#{@region.host_domain_name}] Daily Mail",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_zuckerl(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    mail(
      subject: "[#{@region.host_domain_name}] Buchung Zuckerl von #{@zuckerl.location.name}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_room_booster(room_booster)
    @room_booster = room_booster
    @region = @room_booster.region

    mail(
      subject: "[#{@region.host_domain_name}] Buchung RoomBooster für #{@room_booster.room_offer}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_region_call(region_call)
    @region_call = region_call
    @region = Region.get('kaernten')

    mail(
      subject: "[WeLocally] #{@region_call.gemeinden} möchte andocken!",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def messenger_spam_alert(user)
    @user = user
    @region = @user.region

    mail(
      subject: "[#{@region.host_domain_name}] Messenger Spam Alert - Check User: #{@user.username}",
      from: platform_email("no-reply"),
      to: platform_email("michael", "Michael"),
    )
  end

end
