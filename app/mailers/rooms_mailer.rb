class RoomsMailer
  include MailUtils

  def send_room_offer_online_email(room_offer)
    MandrillMailer.deliver(template: 'notification-room-online', message: email_settings(room_offer))
  end

  private

  def email_settings(room_offer)
    user = room_offer.user
    {
      to: [ { email: user.email } ],
      global_merge_vars: [
        { name: 'username', content: user.username },
        { name: 'first_name', content: user.first_name },
        { name: 'last_name', content: user.last_name },
        { name: 'user_type', content: user.business? ? 'business' : 'normal' },
        { name: 'graetzl_name', content: user.graetzl.name },
        { name: 'graetzl_url', content: graetzl_url(user.graetzl, URL_OPTIONS) },
        { name: 'room_title', content: room_offer.slogan },
        { name: 'room_url', content: room_offer_url(room_offer, URL_OPTIONS) },
        { name: 'room_type', content: I18n.t("activerecord.attributes.room_offer.offer_types_active.#{room_offer.offer_type}") },
        { name: 'room_description', content: room_offer.room_description },
      ]
    }
  end
end
