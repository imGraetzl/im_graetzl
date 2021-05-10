namespace :db do
  desc 'mailchimp batch operations unsubscribe task'
  task mailchimp_batch_unsubscribe: :environment do

    emails = [
      
    ]

    emails.each do |email|
      next if User.find_by_email(email).nil?
      user = User.find_by_email(email)
      user.update_columns(newsletter: false)
    end

    # Excel convert line to strings ""'@"',"
    #g = Gibbon::Request.new
    #g.lists('f606bd9ea4').members.retrieve(params: {"count": "1000", "status": "unsubscribed"})

  end
end
