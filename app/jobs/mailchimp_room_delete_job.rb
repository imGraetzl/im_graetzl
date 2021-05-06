class MailchimpRoomDeleteJob < ApplicationJob

  def perform(user)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = mailchimp_member_id(user)

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        merge_fields: {
          ROOM_TYPE: '',
          ROOM_STATE: '',
          ROOM_TITLE: '',
          ROOM_URL: '',
          ROOM_PLZ: '',
          ROOM_CAT: '',
          ROOM_DATE: ''
        }
      })
      g.lists(list_id).members(member_id).tags.create(body: {
        tags: [{name:"Habe Raum", status:"inactive"}, {name:"Suche Raum", status:"inactive"}]
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
