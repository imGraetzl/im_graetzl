class GoingToMailer < ApplicationMailer

  def going_to_reminder(going_to)
    @going_to = going_to
    @region = @going_to.meeting.region

    headers("X-MC-Tags" => "notification-going-to-reminder")

    mail(
      subject: "Erinnerung: #{@going_to.meeting.name.truncate(45)}",
      from: platform_email("no-reply"),
      to: @going_to.user.email,
    )
  end

  def good_morning_date_charge_reminder(going_to)
    @going_to = going_to
    @meeting = @going_to.meeting
    @region = @going_to.meeting.region

    headers("X-MC-Tags" => "good-morning-date-charge-reminder")

    mail(
      subject: "Good Morning Date - Danke fürs Dabeisein",
      from: platform_email("mirjam", "Mirjam Mieschendahl"),
      to: @going_to.user.email,
    )
  end

end
