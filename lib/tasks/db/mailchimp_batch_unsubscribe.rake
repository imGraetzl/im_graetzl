namespace :db do
  desc 'mailchimp batch operations unsubscribe task'
  task mailchimp_batch_unsubscribe: :environment do

    ARGV.each { |a| task a.to_sym do ; end }

    # heroku run rake db:mailchimp_batch_unsubscribe 0 1000 -a imgraetzl-staging
    list_id = Rails.application.secrets.mailchimp_list_id
    offset = ARGV[1].to_i
    count = ARGV[2].to_i
    logging_count_unsubscribed = 0
    logging_count_already_unsubscribed = 0

    g = Gibbon::Request.new
    g.debug = true
    response = g.lists(list_id).members.retrieve(params: {
      "offset":offset, "count": count, "status": "unsubscribed"
    })
    members = response.body['members']

    members.each do |member|
      email = member['email_address']
      next if User.registered.find_by_email(email).nil?
      user = User.registered.find_by_email(email)
      if user.newsletter?
        user.update_columns(newsletter: false)
        Rails.logger.info("[Mailchimp Batch Unsubscribe]: #{email}: set newsletter to FALSE")
        logging_count_unsubscribed += 1
      else
        Rails.logger.info("[Mailchimp Batch Unsubscribe]: #{email}: already unsubscribed")
        logging_count_already_unsubscribed += 1
      end
    end

    Rails.logger.info("[Mailchimp Batch Unsubscribe]: #{logging_count_unsubscribed}: users unsubscribed")
    Rails.logger.info("[Mailchimp Batch Unsubscribe]: #{logging_count_already_unsubscribed}: users already unsubscribed")

  end
end
