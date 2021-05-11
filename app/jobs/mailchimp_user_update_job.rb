class MailchimpUserUpdateJob < ApplicationJob

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

  def perform(user)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(user)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        merge_fields: {
          FNAME: user.first_name,
          LNAME: user.last_name,
          USERROLE: user.business? ? 'business' : '',
          GRAETZL: user.graetzl.name,
          GR_URL: Rails.application.routes.url_helpers.graetzl_path(user.graetzl),
          PLZ: user.graetzl.districts.first.try(:zip),
          USERNAME: user.username,
          PROFIL_URL: Rails.application.routes.url_helpers.user_path(user),
          L_CATEGORY: user_location_category(user)
        },
        interests: business_user_interests(user)
      })
      if user.newsletter?
        g.lists(list_id).members(member_id).tags.create(body: {
          tags: [{name:"NL False", status:"active"}]
        })
      else
        g.lists(list_id).members(member_id).tags.create(body: {
          tags: [{name:"NL False", status:"inactive"}]
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

  def mailchimp_member_id(user)
    Digest::MD5.hexdigest(user.email.downcase)
  end

end
