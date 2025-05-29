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

  def task_info(task_name, execution, task_starts_at = nil, task_ends_at = nil)
    if Rails.env.production?
      @region = Region.get('wien')
      @task_name = task_name
      @execution = execution
      @task_starts_at = task_starts_at
      @task_ends_at = task_ends_at
      
      mail(
        subject: "[#{@region.host_domain_name}] Task Info: [#{task_name}] #{execution} / #{Time.now}",
        from: platform_email("no-reply"),
        to: platform_email("michael", "Michael"),
      )
    end
  end

  def new_zuckerl(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    mail(
      subject: "[#{@region.host_domain_name}] Buchung Zuckerl von #{@zuckerl.user.full_name}",
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
    @region = Region.get('graz')

    mail(
      subject: "[WeLocally] #{@region_call.gemeinden} möchte andocken!",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_contact_list_entry(contact_list_entry)
    @contact_list_entry = contact_list_entry
    @region = contact_list_entry.region || Region.get('graz')

    mail(
      subject: "[New Contact] für #{@contact_list_entry.via_path}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def messenger_spam_alert(user, messages)
    @user = user
    @region = @user.region
    @messages = messages.sort_by(&:created_at).reverse

    mail(
      subject: "[#{@region.host_domain_name}] Messenger Spam Alert - Check User: #{@user.username}",
      from: platform_email("no-reply"),
      to: platform_email("michael", "Michael"),
    )
  end

end
