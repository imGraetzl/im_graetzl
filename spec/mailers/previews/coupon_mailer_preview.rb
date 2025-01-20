class CouponMailerPreview < ActionMailer::Preview

  def coupon_mail
    CouponMailer.coupon_mail(User.last, Coupon.last)
  end

  def coupon_mail_reminder
    CouponMailer.coupon_mail_reminder(User.last, Coupon.last)
  end

end
