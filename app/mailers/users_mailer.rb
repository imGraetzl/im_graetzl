class UsersMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    headers("X-MC-Tags" => "welcome-mail")
    mail(
      to: @user.email,
      from: "Mirjam | imGrätzl.at <mirjam@imgraetzl.at>",
      subject: "Zum Start gibt es gleich ein paar schöne Chancen als Willkommensgeschenk!",
    )
  end

  def user_confirmation_reminder(user)
    @user = user
    headers("X-MC-Tags" => "user-confirmation-reminder")
    mail(
      to: @user.email,
      from: "imGrätzl.at <wir@imgraetzl.at>",
      subject: "Noch ein Klick zu deinem imGrätzl Account",
    )
  end

  def location_approved(location, user)
    @location = location
    @user = user
    headers("X-MC-Tags" => "location-approved")
    mail(
      to: @user.email,
      from: "Mirjam | imGrätzl.at <mirjam@imgraetzl.at>",
      subject: "Deine Location wurde freigeschalten",
    )
  end

end
