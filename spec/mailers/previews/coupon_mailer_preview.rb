class CouponMailerPreview < ActionMailer::Preview

  def coupon_mail
    CouponMailer.coupon_mail(User.confirmed.first, Coupon.last, :gmd)
  end

  def coupon_mail_reminder
    CouponMailer.coupon_mail_reminder(User.confirmed.first, Coupon.last)
  end

end
