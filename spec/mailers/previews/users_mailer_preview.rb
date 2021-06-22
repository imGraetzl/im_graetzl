class UsersMailerPreview < ActionMailer::Preview

  def welcome_email
    UsersMailer.welcome_email(User.last)
  end

  def user_confirmation_reminder
    UsersMailer.user_confirmation_reminder(User.where(:confirmed_at => nil).last)
  end

  def location_approved
    UsersMailer.location_approved(Location.last, Location.last.users.last)
  end

end
