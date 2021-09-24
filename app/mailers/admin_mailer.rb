class AdminMailer < ApplicationMailer

  def new_zuckerl(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    mail(
      subject: "[#{@region.platform_name}] Buchung Zuckerl von #{@zuckerl.location.name}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

  def new_paid_going_to(going_to)
    @going_to = going_to
    @region = @going_to.meeting.region

    mail(
      subject: "[#{@region.platform_name}] Ticket-Kauf für #{@going_to.meeting.name}",
      from: platform_email("no-reply"),
      to: platform_email("wir"),
    )
  end

end
