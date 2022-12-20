namespace :scheduled do
  desc 'Send Update Goodie Reminder'
  task update_goodie_reminder_mail: :environment do
    Location.approved.goodie.where(updated_at: 6.months.ago.to_date).find_each do |location|
      next if location.user.nil?
      LocationMailer.update_goodie_reminder(location).deliver_now
    end
  end
end
