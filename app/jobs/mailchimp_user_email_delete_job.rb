class MailchimpUserEmailDeleteJob < ApplicationJob

  def perform(email)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(email)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).delete()
    rescue Gibbon::MailChimpError => mce
      Rails.logger.error("subscribe failed: due to #{mce.message}")
      raise mce
    rescue => e
      Rails.logger.error("subscribe failed: due to #{e.message}")
      raise e
    end
  end

  def mailchimp_member_id(email)
    Digest::MD5.hexdigest(email.downcase)
  end
  
end
