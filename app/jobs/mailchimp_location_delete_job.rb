class MailchimpLocationDeleteJob < ApplicationJob

  def perform(location)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(location.user)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        merge_fields: {
          LOCATION: '',
          L_URL: '',
          L_CATEGORY: '',
          L_PLZ: '',
          L_GRAETZL: '',
          L_GR_URL: ''
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
