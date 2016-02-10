class Notifications::DailyMail < MandrillMessage
  MANDRILL_TEMPLATE = 'daily-notifications'
  BLOCKS = [
    {
      name: 'Neue Location Updates',
      types: [Notifications::NewLocationPost]
    },
    {
      name: 'Neue Treffen',
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
    @message = build_message
    @notifications.update_all(sent: true) if super
  end

  private

  attr_accessor :notifications

  def notification_blocks
    BLOCKS.collect{|b| notification_block(b[:name], b[:types])}.compact
  end

  def notification_block(name, types)
    notifications = @notifications.where(type: types)
    unless notifications.empty?
      {
        name: name,
        size: notifications.length,
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
        subject: "Neues aus dem Grätzl #{@user.graetzl.name}",
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
