class MailchimpUserTagJob < ApplicationJob
  queue_as :mailchimp # Spezielle Warteschlange für Mailchimp-Jobs

  def perform(user, tag, status)
    list_id = ENV['MAILCHIMP_LIST_ID']
    member_id = user.mailchimp_member_id

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).tags.create(body: {
        tags: [{name:tag, status: status}]
      })
    rescue Gibbon::MailChimpError => mce
      if mce.status_code == 404
        Rails.logger.warn("MailchimpUserTagJob: User #{user.id} (#{member_id}) nicht gefunden (404). Tag '#{tag}' nicht gesetzt.")
        # Kein raise -> Job wird nicht erneut versucht!
      else
        Rails.logger.error("MailchimpUserTagJob: subscribe failed: due to #{mce.message} (#{mce.status_code})")
        raise mce
      end
    rescue => e
      Rails.logger.error("MailchimpUserTagJob: subscribe failed: due to #{e.message}")
      raise e
    end
  end

end
