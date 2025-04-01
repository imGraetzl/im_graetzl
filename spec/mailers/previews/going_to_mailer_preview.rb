class GoingToMailerPreview < ActionMailer::Preview

  def going_to_reminder
    GoingToMailer.going_to_reminder(GoingTo.last)
  end

end
