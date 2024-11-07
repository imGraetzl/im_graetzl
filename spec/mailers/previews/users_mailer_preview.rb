class UsersMailerPreview < ActionMailer::Preview

  def welcome_email
    UsersMailer.welcome_email(User.last)
  end

  def user_confirmation_reminder
    UsersMailer.user_confirmation_reminder(User.registered.where(:confirmed_at => nil).last)
  end

end
