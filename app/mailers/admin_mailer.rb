class AdminMailer < ApplicationMailer

  def new_zuckerl(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    mail(
      subject: "[#{@region.host_domain_name}] Buchung Zuckerl von #{@zuckerl.location.name}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_paid_going_to(going_to)
    @going_to = going_to
    @region = @going_to.meeting.region

    mail(
      subject: "[#{@region.host_domain_name}] Ticket-Kauf für #{@going_to.meeting.name}",
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
