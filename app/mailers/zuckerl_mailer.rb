class ZuckerlMailer < ApplicationMailer

  def booking_confirmation(zuckerl)
    @zuckerl = zuckerl
    @user = @zuckerl.location.user
    mail(to: @user.email, subject: "Zuckerl Buchungsbestätigung & Infos zur Zahlung")
  end

  def live_information(zuckerl)
    @zuckerl = zuckerl
    @user = @zuckerl.location.user
    mail(to: @user.email, subject: "Dein Zuckerl ist jetzt online")
  end

  def invoice(zuckerl)
    @zuckerl = zuckerl
    @user = @zuckerl.location.user
    attachments["#{@zuckerl.invoice_number}.pdf"] = @zuckerl.zuckerl_invoice.get.body.read
    headers("X-MC-Tags" => "zuckerl-paid")
    mail(to: @user.email, bcc_address: 'michael@imgraetzl.at', subject: "Zahlungsbestätigung deines Zuckerls")
  end

end
