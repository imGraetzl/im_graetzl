class MailchimpRoomDemandUpdateJob < ApplicationJob

  def perform(room)
    list_id = Rails.application.secrets.mailchimp_list_id
    member_id = room.user.mailchimp_member_id

    begin
      g = Gibbon::Request.new
      g.timeout = 30
      g.lists(list_id).members(member_id).update(body: {
        merge_fields: {
          ROOM_TYPE: I18n.t("activerecord.attributes.room_demand.demand_types.#{room.demand_type}"),
          ROOM_STATE: I18n.t("activerecord.attributes.room_demand.statuses.#{room.status}"),
          ROOM_TITLE: room.slogan,
          ROOM_URL: Rails.application.routes.url_helpers.room_demand_path(room),
          ROOM_PLZ: room.districts ? room.districts.map(&:zip).join(", ") : '',
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
