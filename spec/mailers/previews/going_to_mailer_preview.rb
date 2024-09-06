class GoingToMailerPreview < ActionMailer::Preview

  def going_to_reminder
    GoingToMailer.going_to_reminder(GoingTo.last)
  end

  def good_morning_date_charge_reminder
    GoingToMailer.good_morning_date_charge_reminder(GoingTo.last)
  end

end
