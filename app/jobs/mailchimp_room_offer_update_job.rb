class MailchimpRoomOfferUpdateJob < ApplicationJob

  def perform(room)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = room.user.mailchimp_member_id

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        merge_fields: {
          ROOM_TYPE: I18n.t("activerecord.attributes.room_offer.offer_types.#{room.offer_type}"),
          ROOM_STATE: I18n.t("activerecord.attributes.room_offer.statuses.#{room.status}"),
          ROOM_TITLE: room.slogan,
          ROOM_URL: Rails.application.routes.url_helpers.room_offer_path(room),
          ROOM_PLZ: room.district ? room.district.zip : '',
          ROOM_CAT: room.room_categories.map(&:name).join(", "),
          R_UPDATE: room.last_activated_at
        }
      })
      g.lists(list_id).members(member_id).tags.create(body: {
        tags: [{name:"Raumteiler", status:"active"}]
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
