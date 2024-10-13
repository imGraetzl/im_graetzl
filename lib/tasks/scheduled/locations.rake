namespace :scheduled do
  desc 'Send Update Goodie Reminder'
  task update_goodie_reminder_mail: :environment do
    range = (6.months.ago.beginning_of_day)..(6.months.ago.end_of_day)
    Location.approved.goodie.where(updated_at: range).find_each do |location|
      next if location.user.nil?
      LocationMailer.update_goodie_reminder(location).deliver_later
    end
  end
end
