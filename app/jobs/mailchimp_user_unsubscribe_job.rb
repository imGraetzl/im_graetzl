class MailchimpUserUnsubscribeJob < ApplicationJob

  def perform(user)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(user)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        email_address: user.email, status: "unsubscribed",
        merge_fields: {
          NL_STATE: user.newsletter? ? 'true' : 'false',
        },
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
