class UsersMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "welcome-mail")

    mail(
      subject: "Zum Start gibt es gleich ein paar schöne Chancen als Willkommensgeschenk!",
      from: platform_email("mirjam", "Mirjam Mieschendahl"),
      to: @user.email,
    )
  end

  def user_confirmation_reminder(user)
    @user = user
    @region = @user.region

    headers("X-MC-Tags" => "user-confirmation-reminder")

    mail(
      subject: "Noch ein Klick zu deinem #{I18n.t("region.#{@user.region.id}.domain_short")} Account",
      from: platform_email("wir"),
      to: @user.email,
    )
  end

end
