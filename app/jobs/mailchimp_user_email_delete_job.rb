class MailchimpUserEmailDeleteJob < ApplicationJob
  queue_as :mailchimp # Spezielle Warteschlange für Mailchimp-Jobs

  def perform(email)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(email)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).delete()
    rescue Gibbon::MailChimpError => mce
      Rails.logger.error("Mailchimp Error: #{mce.message}")

      if mce.status_code == 405
        Rails.logger.error("Mailchimp Kontakt kann nicht gelöscht werden, Fehler 405: #{email}")
        # Skip Job
        return
      end

      raise mce
    rescue => e
      Rails.logger.error("Mailchimp Error: #{e.message}")
      raise e
    end
  end

  def mailchimp_member_id(email)
    Digest::MD5.hexdigest(email.downcase)
  end
  
end
