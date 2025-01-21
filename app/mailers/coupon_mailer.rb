class CouponMailer < ApplicationMailer

  def coupon_mail(user, coupon)
    @user = user
    @coupon = coupon
    @region = @user.region

    headers("X-MC-Tags" => "coupon-mail")

    mail(
      subject: "Unser Dankeschön an dich als #{I18n.t("region.#{@user.region.id}.domain_short")} Superfan",
      from: platform_email("mirjam", "Mirjam Mieschendahl"),
      to: @user.email,
    )
  end

  def coupon_mail_reminder(user, coupon)
    @user = user
    @coupon = coupon
    @region = @user.region

    headers("X-MC-Tags" => "coupon-mail-reminder")

    mail(
      subject: "Fast vorbei: Dein Superfan-Angebot endet bald!",
      from: platform_email("mirjam", "Mirjam Mieschendahl"),
      to: @user.email,
    )
  end

end
