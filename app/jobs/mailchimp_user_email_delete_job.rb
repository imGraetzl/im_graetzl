class MailchimpUserEmailDeleteJob < ApplicationJob
  queue_as :mailchimp

  def perform(email)
    list_id = ENV['MAILCHIMP_LIST_ID']
    member_id = mailchimp_member_id(email)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).delete
    rescue Gibbon::MailChimpError => e
      case e.status_code
      when 404
        Rails.logger.info("[Mailchimp]: Mitglied nicht gefunden – evtl. bereits gelöscht (#{email})")
        # Kein raise = Job gilt als erfolgreich
      when 405
        Rails.logger.warn("[Mailchimp]: Löschen nicht erlaubt (405) für #{email}")
        # Kein raise = Job gilt als erfolgreich
      else
        Rails.logger.error("[Mailchimp]: Fehler #{e.status_code} bei #{email}: #{e.message}")
        raise e # → retry bei temporären Fehlern
      end
    rescue => e
      Rails.logger.error("[Mailchimp]: Unerwarteter Fehler im Mailchimp-Job (#{email}): #{e.message}")
      raise e
    end
  end

  private

  def mailchimp_member_id(email)
    Digest::MD5.hexdigest(email.downcase)
  end
end
