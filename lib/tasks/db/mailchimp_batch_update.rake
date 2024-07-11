namespace :db do
  desc 'mailchimp batch operations update task'
  task mailchimp_batch_update: :environment do

    ARGV.each { |a| task a.to_sym do ; end }

    list_id = Rails.application.secrets.mailchimp_list_id
    method = ARGV[1] # PATCH: Update existing, PUT: create & update
    user_from = ARGV[2].to_i # Start User ID
    user_to = ARGV[3].to_i # End User ID
    members = []

    def mailchimp_member_id(user)
      Digest::MD5.hexdigest(user.email.downcase)
    end

    def business_user_interests(user)
      mailchimp_interests = {}
      user.try(:business_interests).each do |interest|
        mailchimp_interests[interest.mailchimp_id] = true if interest.mailchimp_id.present?
      end
      return mailchimp_interests
    end

    def user_location_category(user)
      user.location_category.try(:name) ? user.location_category.try(:name) : ''
    end

    User.where(id: user_from..user_to).each do |user|
      next if !user.confirmed_at?

      # USER MERGE FIELDS
      merge_fields = {
        USERID: user.id,
        FNAME: user.first_name,
        LNAME: user.last_name,
        USERROLE: user.business? ? 'business' : '',
        GRAETZL: user.graetzl.name,
        GR_URL: Rails.application.routes.url_helpers.graetzl_path(user.graetzl),
        PLZ: user.address_zip? ? user.address_zip : '',
        USERNAME: user.username,
        PROFIL_URL: Rails.application.routes.url_helpers.user_path(user),
        SIGNUP: user.created_at,
        L_CATEGORY: user_location_category(user),
        REGION: user.region.name,
        REGION_URL: user.region.host,
      }

      member = {
        method: method, # PATCH: Update existing, PUT: create & update
        path: "lists/#{ list_id }/members/#{mailchimp_member_id(user)}",
        operation_id: "batch-member-#{user.id}",
        body: {
          email_address: user.email,
          status_if_new: "subscribed",
          merge_fields: merge_fields,
          interests: business_user_interests(user)
        }.to_json
      }
      members << member
    end

    begin
      g = Gibbon::Request.new
      g.debug = true
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
