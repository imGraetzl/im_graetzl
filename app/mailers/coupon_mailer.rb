class CouponMailer < ApplicationMailer

  def coupon_mail(user, coupon, type)
    @user = user
    @coupon = coupon
    @type = type
    @region = @user.region

    headers("X-MC-Tags" => "coupon-mail")

    mail(
      subject: "Unser Dankeschön für dich - wir feiern 10 Jahre imGrätzl",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  def coupon_mail_reminder(user, coupon)
    @user = user
    @coupon = coupon
    @region = @user.region

    headers("X-MC-Tags" => "coupon-mail-reminder")

    mail(
      subject: "Fast vorbei: Dein “10 Jahre imGrätzl” Angebot endet bald!",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

end
