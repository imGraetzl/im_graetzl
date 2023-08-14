class MailchimpGuestSubscribeJob < ApplicationJob

  def perform(email, options = {})
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(email)

    merge_fields = {
      FNAME: options[:first_name] ? options[:first_name] : '',
      LNAME: options[:last_name] ? options[:last_name] : '',
      REGION: options[:region_id] ? options[:region_id] : '',
    }
    
    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).upsert(body: {
        email_address: email, status: "subscribed",
        merge_fields: merge_fields
      })

      if options[:tags]
        options[:tags].each do |tag|
          g.lists(list_id).members(member_id).tags.create(body: {
            tags: [{name:tag, status:"active"}]
          })
        end
      end

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
