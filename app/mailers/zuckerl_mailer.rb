class ZuckerlMailer < ApplicationMailer

  def booking_confirmation(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    mail(
      subject: "Zuckerl Buchungsbestätigung & Infos zur Zahlung",
      from: platform_email("no-reply"),
      to: @zuckerl.user.email,
    )
  end

  def live_information(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    mail(
      subject: "Dein Zuckerl ist jetzt online",
      from: platform_email("no-reply"),
      to: @zuckerl.user.email,
    )
  end

  def invoice(zuckerl)
    @zuckerl = zuckerl
    @region = @zuckerl.region

    attachments["Zuckerl_#{@zuckerl.invoice_number}.pdf"] = @zuckerl.zuckerl_invoice.get.body.read
    headers("X-MC-Tags" => "zuckerl-paid")

    mail(
      subject: "Zahlungsbestätigung deines Zuckerls",
      from: platform_email("no-reply"),
      to: @zuckerl.user.email,
      bcc: 'michael@imgraetzl.at',
    )
  end

end
