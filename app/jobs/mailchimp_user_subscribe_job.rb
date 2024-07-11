class MailchimpUserSubscribeJob < ApplicationJob

  def perform(user)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = user.mailchimp_member_id

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

    #merge_fields.merge!(user_location(user))

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).upsert(body: {
        email_address: user.email, status: "subscribed",
        merge_fields: merge_fields,
        interests: business_user_interests(user)
      })
      g.lists(list_id).members(member_id).tags.create(body: {
        tags: [{name:"#{user.region.name}", status:"active"}]
      })
      if user.newsletter?
        g.lists(list_id).members(member_id).tags.create(body: {
          tags: [{name:"NL False", status:"inactive"}]
        })
      else
        g.lists(list_id).members(member_id).tags.create(body: {
          tags: [{name:"NL False", status:"active"}]
        })
      end
      if user.subscribed?
        g.lists(list_id).members(member_id).tags.create(body: {
          tags: [{name:"Abo", status:"active"}]
        })
      else
        g.lists(list_id).members(member_id).tags.create(body: {
          tags: [{name:"Abo", status:"inactive"}]
        })
      end
    rescue Gibbon::MailChimpError => mce
      Rails.logger.error("subscribe failed: due to #{mce.message}")
      raise mce
    rescue => e
      Rails.logger.error("subscribe failed: due to #{e.message}")
      raise e
    end
  end

  #def user_location(user)
  #  if user.locations.approved.empty?
  #    location_fieds = {
  #      LOCATION: "",
  #      L_URL: "",
  #      L_PLZ: "",
  #      L_GRAETZL: "",
  #      L_GR_URL: "",
  #    }
  #  else
  #    location = user.locations.approved.last
  #    graetzl = location.graetzl
  #    location_fieds = {
  #      LOCATION: location.name,
  #      L_URL: Rails.application.routes.url_helpers.graetzl_location_path(graetzl, location),
  #      L_CATEGORY: location.location_category.try(:name),
  #      L_PLZ: location.address_zip? ? location.address_zip : '',
  #      L_GRAETZL: graetzl.name,
  #      L_GR_URL: Rails.application.routes.url_helpers.graetzl_path(graetzl),
  #    }
  #  end
  #  return location_fieds
  #end

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

end
