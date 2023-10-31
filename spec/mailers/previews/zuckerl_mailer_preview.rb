class ZuckerlMailerPreview < ActionMailer::Preview

  def approved
    ZuckerlMailer.approved(Zuckerl.last)
  end

  def invoice
    ZuckerlMailer.invoice(Zuckerl.debited.last)
  end

  def live
    ZuckerlMailer.live(Zuckerl.last)
  end

  def payment_failed
    ZuckerlMailer.payment_failed(Zuckerl.last)
  end

end
