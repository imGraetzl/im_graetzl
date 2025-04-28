class ZuckerlMailer < ApplicationMailer

  def approved(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region
    headers("X-MC-Tags" => "zuckerl-approved")
    mail(
      subject: "Dein Zuckerl wurde freigeschalten.",
      from: platform_email("no-reply"),
      to: @zuckerl.user.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def invoice(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region
    headers("X-MC-Tags" => "zuckerl-invoice")
    attachments["Zuckerl_#{@zuckerl.invoice_number}.pdf"] = @zuckerl.zuckerl_invoice.get.body.read
    mail(
      subject: "Dein Zuckerl wurde bezhalt, anbei deine Rechnung.",
      from: platform_email("no-reply"),
      to: @zuckerl.user.email,
    )
  end

  def live(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region
    headers("X-MC-Tags" => "zuckerl-live")
    mail(
      subject: "Dein Zuckerl ist jetzt online",
      from: platform_email("no-reply"),
      to: @zuckerl.user.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

  def payment_failed(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region
    headers("X-MC-Tags" => "zuckerl-payment-failed")
    mail(
      subject: "Es gab Probleme bei deiner Zuckerl Abbuchung, bitte überprüfe deine Zahlungsmethode.",
      from: platform_email('no-reply'),
      to: @zuckerl.user.email,
      bcc: platform_admin_email('michael@imgraetzl.at'),
    )
  end

end
