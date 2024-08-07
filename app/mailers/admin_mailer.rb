class AdminMailer < ApplicationMailer

  def daily_mail
    @region = Region.get('wien')

    mail(
      subject: "[#{@region.host_domain_name}] Daily Mail",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
      cc: "lena@imgraetzl.at, carina@imgraetzl.at"
    )
  end

  def info(task_name, progress, task_starts_at = nil, task_ends_at = nil)
    @region = Region.get('wien')
    @task_name = task_name
    @progress = progress
    @task_starts_at = task_starts_at
    @task_ends_at = task_ends_at
    
    mail(
      subject: "[#{@region.host_domain_name}] Task Info: #{task_name} / #{progress} at #{Time.now}",
      from: platform_email("no-reply"),
      to: platform_email("michael", "Michael"),
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
      subject: "[#{@region.host_domain_name}] Buchung RaumPusher für #{@room_booster.room_offer}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_crowd_booster(campaign, boost_amount)
    @boost_amount = boost_amount
    @campaign = campaign
    @region = @campaign.region

    mail(
      subject: "[#{@region.host_domain_name}] Kampagnen Booster für #{@campaign}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_crowd_boost_charge(crowd_boost_charge)
    @crowd_boost_charge = crowd_boost_charge
    @region = @crowd_boost_charge.region

    mail(
      subject: "[#{@region.host_domain_name}] CrowdBoost Aufladung für #{@crowd_boost_charge.crowd_boost}",
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
