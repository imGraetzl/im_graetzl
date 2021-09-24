class GoingToMailer < ApplicationMailer

  def send_invoice(going_to)
    @going_to = going_to
    @region = @going_to.meeting.region

    attachments["#{@going_to.invoice_number}.pdf"] = @going_to.invoice.get.body.read
    headers("X-MC-Tags" => "going-to-invoice")

    mail(
      subject: "Infos zu deinem Ticket",
      from: platform_email("no-reply"),
      to: @going_to.user.email,
    )
  end

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

end
