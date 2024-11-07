namespace :scheduled do
  desc 'Marketing Mail - All imGrätzl (Region Wien) Users'
  task agb_change_and_crowdfunding: :environment do

    region = Region.get('wien')

    # heroku rake scheduled:agb_change_and_crowdfunding -a imgraetzl-staging

    # For Testing
    # user = User.registered.where(email: ['michael.walchhuetter@gmail.com'])

    User.confirmed.in(region).find_each do |user|
      MarketingMailer.agb_change_and_crowdfunding(user).deliver_later
    end

  end
end
