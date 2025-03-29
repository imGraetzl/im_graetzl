class GoingToMailerPreview < ActionMailer::Preview

  def going_to_reminder
    GoingToMailer.going_to_reminder(GoingTo.last)
  end

  def good_morning_date_thankyou
    GoingToMailer.good_morning_date_thankyou(GoingTo.first)
  end

end
