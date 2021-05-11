namespace :db do
  desc 'mailchimp batch operations unsubscribe task'
  task mailchimp_batch_unsubscribe: :environment do

    ARGV.each { |a| task a.to_sym do ; end }

    # heroku run rake db:mailchimp_batch_unsubscribe 0 1000 -a imgraetzl-staging
    list_id = Rails.application.secrets.mailchimp_list_id
    offset = ARGV[1].to_i
    count = ARGV[2].to_i

    g = Gibbon::Request.new
    response = g.lists(list_id).members.retrieve(params: {
      "offset":"#{offset}", "count": "#{count}", "status": "unsubscribed"
    })
    members = response.body['members']

    members.each do |member|
      email = member['email_address']
      next if User.find_by_email(email).nil?
      user = User.find_by_email(email)
      user.update_columns(newsletter: false)
      Rails.logger.info("[Mailchimp Batch Unsubscribe]: #{email}: unsubscribed")
    end

  end
end
