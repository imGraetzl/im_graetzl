class Notifications::DailyMail < Notifications::MandrillMessage
  MANDRILL_TEMPLATE = "notification-daily-mail"
  BLOCKS = [
    {
      name: 'Neues von Locations aus dem Grätzl',
      types: [Notifications::NewLocationPost]
    },
    {
      name: 'Neue Treffen im Grätzl',
      types: [Notifications::NewMeeting]
    },
    {
      name: 'Neue Beiträge im Grätzl',
      types: [Notifications::NewUserPost]
    }
  ]

  def initialize(user)
    super(user)
    @notifications = @user.notifications_of_the_day
    @template_name = MANDRILL_TEMPLATE
  end

  def deliver
    if message = build_message
      mandrill_client.messages.send_template(
        @template_name,
        @template_content,
        message
      )
    end
  end

  private

  attr_reader :notifications

  def notification_blocks
    BLOCKS.collect{|b| notification_block(b[:name], b[:types])}.compact
  end

  def notification_block(name, types)
    notifications = @notifications.where(type: types)
    unless notifications.empty?
      {
        name: name,
        notifications: notifications.collect{|n| n.mail_vars}
      }
    end
  end

  def build_message
    blocks = notification_blocks
    unless blocks.empty?
      {
        to: [ { email: @user.email } ],
        from_email: Rails.configuration.x.mandril_from_email,
        from_name: Rails.configuration.x.mandril_from_name,
        subject: 'daily mail...?',
        global_merge_vars: basic_message_vars,
        merge_vars: [
          rcpt: @user.email,
          vars: [
            { name: 'notification_blocks', content: notification_blocks }
          ]
        ]
      }
    end
  end
end
