namespace :scheduled do
  desc 'Marketing Mail - All imGrätzl (Region Wien) Users'
  task agb_change_and_welocally: :environment do

    region = Region.get('wien')

    # For Testing
    # heroku rake scheduled:agb_change_and_welocally -a imgraetzl-staging
    user = User.where(email: ['michael.walchhuetter@gmail.com','mirjam.mieschendahl@gmail.com'])

    #User.in(region).confirmed.find_each do |user|
    user.find_each do |user|
      MarketingMailer.agb_change_and_welocally(user).deliver_now
    end

  end
end
