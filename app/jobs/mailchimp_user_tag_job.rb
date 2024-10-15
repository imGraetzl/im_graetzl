class MailchimpUserTagJob < ApplicationJob
  queue_as :mailchimp # Spezielle Warteschlange für Mailchimp-Jobs

  def perform(user, tag, status)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = user.mailchimp_member_id

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).tags.create(body: {
        tags: [{name:tag, status: status}]
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
