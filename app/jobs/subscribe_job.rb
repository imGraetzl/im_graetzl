class SubscribeJob < ApplicationJob
  def perform(user)
    mailchimp_list_id = Rails.application.secrets.mailchimp_list_id
    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(mailchimp_list_id).members.create(body: {
        email_address: user.email, status: "subscribed",
        merge_fields: {
          USERID: user.id,
          FNAME: user.first_name,
          LNAME: user.last_name,
          USERROLE: user.role || '',
          GRAETZL: user.graetzl.name,
          GR_URL: Rails.application.routes.url_helpers.graetzl_path(user.graetzl),
          PLZ: user.graetzl.districts.first.try(:zip),
          USERNAME: user.username,
          PROFIL_URL: Rails.application.routes.url_helpers.user_path(user),
          NEWSLETTER: user.newsletter.to_s
        }
      })
    rescue Gibbon::MailChimpError => mce
      SuckerPunch.logger.error("subscribe failed: due to #{mce.message}")
      raise mce
    rescue Exception => e
      SuckerPunch.logger.error("subscribe failed: due to #{e.message}")
      raise e
    end
  end
end
