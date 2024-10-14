namespace :scheduled do
  desc 'Remind Attendees 1 Day before Meeting Starts'
  task going_to_reminder: :environment do
    GoingTo.where("going_to_date = ?", Date.tomorrow).find_each do |going_to|
      GoingToMailer.going_to_reminder(going_to).deliver_later
    end
  end

  desc 'Remind Attendees 1 Day after Good Morning Date'
  task good_morning_date_charge_reminder: :environment do
    GoingTo.where("going_to_date = ?", Date.today).find_each do |going_to|
      next unless going_to.attendee? && going_to.meeting.good_morning_date?
      GoingToMailer.good_morning_date_charge_reminder(going_to).deliver_later
    end
  end
end
