namespace :scheduled do
  desc 'Remind new unconfirmed Users 1 Day after Registration'
  task user_confirmation_reminder: :environment do

    puts "--- User Confirmation Reminder Mail at: #{Time.now} ---"
    User.where("created_at = ?", Date.yesterday).where(:confirmed_at => nil).find_each do |user|
      #GoingToMailer.going_to_reminder(going_to).deliver_now
      # im mail dann: confirmation_url(confirmation_token: user.confirmation_token)
    end

  end
end
