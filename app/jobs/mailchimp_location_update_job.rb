class MailchimpLocationUpdateJob < ApplicationJob

  def perform(location)
    return if location.user.nil?

    graetzl = location.graetzl
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(location.user)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        merge_fields: {
          LOCATION: location.name,
          L_URL: Rails.application.routes.url_helpers.graetzl_location_path(graetzl, location),
          L_CATEGORY: location.location_category.try(:name),
          L_PLZ: location.address_zip? ? location.address_zip : '',
          L_GRAETZL: graetzl.name,
          L_GR_URL: Rails.application.routes.url_helpers.graetzl_path(graetzl),
        }
      })
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
