class Notification::SummaryMail
  include MailUtils

  MANDRILL_TEMPLATE = 'summary-mail'

  GRAETZL_BLOCKS = [
    {
      name: 'Neue Treffen',
      types: [Notifications::NewMeeting]
    },
    {
      name: 'Neue Location Updates',
      types: [Notifications::NewLocationPost]
    },
    {
      name: 'Neu auf imGrätzl - Sag Hallo',
      types: [Notifications::NewLocation]
    },
    {
      name: 'Neue Ideen im Grätzl',
      types: [Notifications::NewUserPost, Notifications::NewAdminPost]
    }
  ]

  ROOM_BLOCKS = [
    {
      name: 'Neue Räume zum Andocken',
      types: [Notifications::NewRoomOffer]
    },
    {
      name: 'Auf der Suche nach Raum',
      types: [Notifications::NewRoomDemand]
    },
    {
      name: 'Neuer Raumteiler Call',
      types: [Notifications::NewRoomCall]
    }
  ]

  PERSONAL_BLOCKS = [
    {
      name: 'Also commented',
      types: [Notifications::AlsoCommentedAdminPost, Notifications::AlsoCommentedLocationPost,
        Notifications::AlsoCommentedMeeting, Notifications::AlsoCommentedRoomDemand,
        Notifications::AlsoCommentedRoomOffer, Notifications::AlsoCommentedUserPost]
    },
    {
      name: 'Auf der Suche nach Raum',
      types: [Notifications::NewRoomDemand]
    },
    {
      name: 'Neuer Raumteiler Call',
      types: [Notifications::NewRoomCall]
    }
  ]

  SUMMARY_TYPES = {
    graetzl: GRAETZL_BLOCKS,
    rooms: ROOM_BLOCKS,
    personal: PERSONAL_BLOCKS,
  }

  def initialize(user, type, period)
    @user = user
    @period = period
    @type = type
  end

  def deliver
    if @period == :daily
      notifications = @user.pending_daily_notifications
    elsif @period == :weekly
      notifications = @user.pending_weekly_notifications
    else
      return
    end

    notification_types = SUMMARY_TYPES[@type].map{|b| b[:types] }.flatten.map(&:to_s)
    notifications = notifications.where(type: notification_types)
    return if notifications.empty?

    MandrillMailer.deliver(template: MANDRILL_TEMPLATE, message: {
      to: [ { email: @user.email } ],
      from_email: FROM_EMAIL,
      from_name: FROM_NAME,
      subject: mail_title,
      google_analytics_domains: ['staging.imgraetzl.at', 'www.imgraetzl.at'],
      google_analytics_campaign: 'daily-mail',
      global_merge_vars: global_vars,
      merge_vars: [
        rcpt: @user.email,
        vars: [
          { name: 'notification_blocks', content: notification_block_vars(notifications) }
        ]
      ]
    })

    notifications.update_all(sent: true)
  end

  private

  def global_vars
    [
      { name: 'username', content: @user.username },
      { name: 'edit_user_url', content: edit_user_url(URL_OPTIONS) },
      { name: 'graetzl_name', content: @user.graetzl.name },
      { name: 'graetzl_url', content: graetzl_url(@user.graetzl, URL_OPTIONS) }
    ]
  end

  def notification_block_vars(notifications)
    block_mail_vars = []
    SUMMARY_TYPES[@type].each do |block|
      block_notifications = notifications.select{|n| n.type.in?(block[:types].map(&:to_s))}
      if block_notifications.present?
        block_mail_vars << {
          name: block[:name],
          size: block_notifications.length,
          notifications: block_notifications.map(&:mail_vars)
        }
      end
    end
    block_mail_vars
  end

  def mail_title
    case @type
    when :graetzl
      "Neues aus dem Grätzl #{@user.graetzl.name}"
    when :rooms
      "Neue Raumteiler aus dem Grätzl #{@user.graetzl.name}"
    when :personal
      "Neue aus dem imGraetzl.at"
    end
  end

end
