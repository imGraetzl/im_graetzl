class RoomsMailer
  include MailUtils

  def send_new_room_offer_email(room_offer)
    MandrillMailer.deliver(template: 'notification-room-online-stgg', message: room_offer_settings(room_offer))
  end

  def send_new_room_demand_email(room_demand)
    MandrillMailer.deliver(template: 'notification-room-online-stgg', message: room_demand_settings(room_demand))
  end

  private

  def room_offer_settings(room_offer)
    {
      to: [ { email: room_offer.user.email } ],
      global_merge_vars: [
        { name: 'type', content: 'room_offer' },
        { name: 'room_title', content: room_offer.slogan },
        { name: 'room_url', content: room_offer_url(room_offer, URL_OPTIONS) },
        { name: 'create_group_url', content: new_group_url(room_offer_id: room_offer.id) },
        { name: 'room_type', content: I18n.t("activerecord.attributes.room_offer.offer_types.#{room_offer.offer_type}") },
        { name: 'room_description', content: room_offer.room_description },
        { name: 'room_categories', content: room_offer.room_categories.map(&:name).join(", ") },
        { name: 'room_picture_url', content: asset_url(room_offer, :cover_photo) },
        { name: 'cover_photo_url', content: Notifications::ImageService.new.cover_photo_url(room_offer) },
      ] + user_vars(room_offer.user)
    }
  end

  def room_demand_settings(room_demand)
    {
      to: [ { email: room_demand.user.email } ],
      global_merge_vars: [
        { name: 'type', content: 'room_demand' },
        { name: 'room_title', content: room_demand.slogan },
        { name: 'room_url', content: room_demand_url(room_demand, URL_OPTIONS) },
        { name: 'room_type', content: I18n.t("activerecord.attributes.room_demand.demand_types.#{room_demand.demand_type}") },
        { name: 'room_description', content: room_demand.demand_description },
        { name: 'room_categories', content: room_demand.room_categories.map(&:name).join(", ") },
        { name: 'room_picture_url', content: asset_url(room_demand, :avatar) },
        { name: 'owner_avatar_url', content: Notifications::ImageService.new.avatar_url(room_demand) },
      ] + user_vars(room_demand.user)
    }
  end

  def user_vars(user)
    [
      { name: 'username', content: user.username },
      { name: 'first_name', content: user.first_name },
      { name: 'last_name', content: user.last_name },
      { name: 'user_type', content: user.business? ? 'business' : 'normal' },
      { name: 'graetzl_name', content: user.graetzl.name },
      { name: 'graetzl_url', content: graetzl_url(user.graetzl, URL_OPTIONS) },
      { name: 'user_avatar_url', content: Notifications::ImageService.new.avatar_url(user) },
    ]
  end

  def asset_url(resource, asset_name)
    host = "https://#{Refile.cdn_host || default_host}"
    Refile.attachment_url(resource, asset_name, host: host)
  end

  def default_host
    Rails.application.config.action_mailer.default_url_options[:host]
  end
end
