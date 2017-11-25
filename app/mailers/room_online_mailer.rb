class RoomOnlineMailer
  include MailUtils

  def send_room_online_email(user)
    MandrillMailer.deliver(template: 'notification-room-online', message: email_settings(user))
  end

  private

  def email_settings(user)
    {
      to: [ { email: user.email } ],
      global_merge_vars: [
        { name: 'username', content: user.username },
        { name: 'first_name', content: user.first_name },
        { name: 'last_name', content: user.last_name },
        { name: 'graetzl_name', content: user.graetzl.name },
        { name: 'graetzl_url', content: graetzl_url(user.graetzl, URL_OPTIONS) }
      ]
    }
  end
end
