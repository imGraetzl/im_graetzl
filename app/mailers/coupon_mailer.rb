class CouponMailer < ApplicationMailer

  def coupon_mail(user, coupon, type)
    @user = user
    @coupon = coupon
    @type = type
    @region = @user.region

    headers("X-MC-Tags" => "coupon-mail-#{@type.to_s}")

    subject_line = case type.to_sym
    when :gmd
      "Good Morning Date - Danke fürs Dabeisein"
    else
      "Unser Dankeschön für dich - wir feiern 10 Jahre imGrätzl"
    end

    mail(
      subject: subject_line,
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  def coupon_mail_reminder(user, coupon)
    @user = user
    @coupon = coupon
    @region = @user.region
    @type = type_from_coupon_code(coupon)

    headers("X-MC-Tags" => "coupon-mail-reminder-#{@type}")

    subject_line = case @type
    when :gmd
      "Fast vorbei: Dein Good Morning Date Gutschein läuft bald ab!"
    else
      "Fast vorbei: Dein “10 Jahre imGrätzl” Angebot endet bald!"
    end

    mail(
      subject: subject_line,
      from: platform_email("wir"),
      to: @user.email,
    )
  end

  private

  def type_from_coupon_code(coupon)
    prefix = coupon.code.split("-")[2][0] rescue nil

    case prefix
    when "G" then :gmd
    when "L" then :location
    when "M" then :meeting
    else :unknown
    end
  end

end
