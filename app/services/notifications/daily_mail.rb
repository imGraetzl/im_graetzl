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

  attr_reader :notifications

  def initialize(user)
    super(user)
    @notifications = @user.notifications_of_the_day
    #TODO: build message only if notification_blocks not empty
    @message = build_message
    @template_name = MANDRILL_TEMPLATE
  end

  private

  def notification_blocks
    BLOCKS.collect{|b| notification_block(b[:name], b[:types])}.compact
  end

  def notification_block(name, types)
    if notifications = @notifications.where(type: types)
      unless notifications.empty?
        {
          name: name,
          notifications: notifications.collect{|n| n.mail_vars}
        }
      end
    end
  end

  def build_message
    # {
    #   to: [ { email: @user.email } ],
    #   from_email: Rails.configuration.x.mandril_from_email,
    #   from_name: Rails.configuration.x.mandril_from_name,
    #   subject: @notification.mail_subject,
    #   global_merge_vars: basic_message_vars,
    #   merge_vars: [
    #     rcpt: @user.email,
    #     vars: @notification.basic_mail_vars + [
    #       { name: 'notification', content: @notification.mail_vars }
    #     ]
    #   ]
    # }
  end
end
