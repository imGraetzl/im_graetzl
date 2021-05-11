namespace :db do
  desc 'mailchimp batch operations update task'
  task mailchimp_batch_update: :environment do

    def business_user_interests(user)
      mailchimp_interests = {}
      user.try(:business_interests).each do |interest|
        mailchimp_interests[interest.mailchimp_id] = true if interest.mailchimp_id.present?
      end
      return mailchimp_interests
    end

    def user_location_category(user)
      if user.locations.empty?
        user.location_category.try(:name) ? user.location_category.try(:name) : ''
      else
        ''
      end
    end

    list_id = Rails.application.secrets.mailchimp_list_id
    members = []

    User.find_each do |user|
      member = {
        method: "POST",
        path: "lists/#{ list_id }/members",
        operation_id: "batch-member-#{user.id}",
        body: {
          email_address: user.email, status: "subscribed",
          merge_fields: {
            USERID: user.id,
            FNAME: user.first_name,
            LNAME: user.last_name,
            USERROLE: user.business? ? 'business' : '',
            GRAETZL: user.graetzl.name,
            GR_URL: Rails.application.routes.url_helpers.graetzl_path(user.graetzl),
            PLZ: user.graetzl.districts.first.try(:zip),
            USERNAME: user.username,
            PROFIL_URL: Rails.application.routes.url_helpers.user_path(user),
            NEWSLETTER: user.newsletter.to_s,
            SIGNUP: user.created_at,
            ORIGIN: user.origin? ? user.origin : '',
            #L_CATEGORY: user_location_category(user)
          },
          interests: business_user_interests(user)
        }.to_json
      }
      members << member
    end

    begin
      g = Gibbon::Request.new
      #g.debug = true
      g.batches.create(body: {
        operations: members
      })
    rescue Gibbon::MailChimpError => mce
      Rails.logger.error("subscribe failed: due to #{mce.message}")
      raise mce
    rescue => e
      Rails.logger.error("subscribe failed: due to #{e.message}")
      raise e
    end

  end
end
