namespace :scheduled do
  desc 'Remind new unconfirmed Users 1 Day after Registration'
  task user_confirmation_reminder: :environment do

    puts "--- User Confirmation Reminder Mail at: #{Time.now} ---"
    User.where("DATE(created_at) = ?", Date.yesterday).where(:confirmed_at => nil).find_each do |user|
      UsersMailer.user_confirmation_reminder(user).deliver_now
    end

  end
end
