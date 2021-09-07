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

    # LOCATION MERGE FIELDS
    def user_location(user)
      if user.locations.approved.empty?
        location_fieds = {
          LOCATION: "",
          L_URL: "",
          L_PLZ: "",
          L_GRAETZL: "",
          L_GR_URL: "",
        }
      else
        location = user.locations.approved.last
        graetzl = location.graetzl
        location_fieds = {
          LOCATION: location.name,
          L_URL: Rails.application.routes.url_helpers.graetzl_location_path(graetzl, location),
          L_CATEGORY: location.location_category.try(:name),
          L_PLZ: location.address_zip? ? location.address_zip : '',
          L_GRAETZL: graetzl.name,
          L_GR_URL: Rails.application.routes.url_helpers.graetzl_path(graetzl),
        }
      end
      return location_fieds
    end

    # ROOM MERGE FIELDS
    def user_room(user)
      if !user.room_offers.empty?
        room = user.room_offers.last
        room_fieds = {
          ROOM_TYPE: I18n.t("activerecord.attributes.room_offer.offer_types.#{room.offer_type}"),
          ROOM_STATE: I18n.t("activerecord.attributes.room_offer.statuses.#{room.status}"),
          ROOM_TITLE: room.slogan,
          ROOM_URL: Rails.application.routes.url_helpers.room_offer_path(room),
          ROOM_PLZ: room.district.zip,
          ROOM_CAT: room.room_categories.map(&:name).join(", "),
          R_UPDATE: room.last_activated_at
        }
      elsif !user.room_demands.empty?
        room = user.room_demands.last
        room_fieds = {
          ROOM_TYPE: I18n.t("activerecord.attributes.room_demand.demand_types.#{room.demand_type}"),
          ROOM_STATE: I18n.t("activerecord.attributes.room_demand.statuses.#{room.status}"),
          ROOM_TITLE: room.slogan,
          ROOM_URL: Rails.application.routes.url_helpers.room_demand_path(room),
          ROOM_PLZ: room.districts.map(&:zip).join(", "),
          ROOM_CAT: room.room_categories.map(&:name).join(", "),
          R_UPDATE: room.last_activated_at
        }
      else
        room_fieds = {
          ROOM_TYPE: "",
          ROOM_STATE: "",
          ROOM_TITLE: "",
          ROOM_URL: "",
          ROOM_PLZ: "",
          ROOM_CAT: "",
          R_UPDATE: ""
        }
      end
      return room_fieds
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
        ORIGIN: user.origin? ? user.origin : '',
        L_CATEGORY: user_location_category(user),
        NL_STATE: user.newsletter? ? 'true' : 'false',
      }

      merge_fields.merge!(user_location(user))
      merge_fields.merge!(user_room(user))

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
