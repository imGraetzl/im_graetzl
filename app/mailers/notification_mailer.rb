class NotificationMailer < ApplicationMailer
  before_action :prepend_view_paths

  def send_immediate(notification)
    @notification = notification
    @user = @notification.user
    @region = @notification.region

    headers(
      "X-MC-Tags" => "notification-immediate",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "notification-immediate-#{@notification.mail_template}",
    )

    Rails.logger.info("[Immediate Mail] #{@user.email} - #{@notification.mail_subject}")

    mail(
      subject: @notification.mail_subject,
      from: platform_email('no-reply'),
      to: @user.email,
      template_name: "immediate/#{@notification.mail_template}"
    )

    @notification.update(sent: true)
  end

  GRAETZL_SUMMARY_BLOCKS = {
    'Neue Crowdfunding Kampagnen wurden gestartet' => [
      Notifications::NewCrowdCampaign
    ],
    'Neue Schaufenster' => [
      Notifications::NewLocation
    ],
    'Neue Räume zum Andocken' => [
      Notifications::NewRoomOffer
    ],
    'Auf der Suche nach Raum' => [
      Notifications::NewRoomDemand
    ],
    'Neue Treffen' => [
      Notifications::NewMeeting
    ],
    'Neue Crowdfunding Kampagnen Updates' => [
      Notifications::NewCrowdCampaignPost
    ],
    'Neue Coop & Share Marktplatz Anbegote' => [
      Notifications::NewCoopDemand
    ],
    'Neue Schaufenster Updates' => [
      Notifications::NewLocationPost
    ],
    'Aktuelle Menüpläne' => [
      Notifications::NewLocationMenu
    ],
    'Neue Geräteteiler' => [
      Notifications::NewToolOffer
    ],
    'Auf der Suche nach einem Gerät' => [
      Notifications::NewToolDemand
    ],
  }

  ZUCKERL_BLOCK_POSITION = 3

  def summary_graetzl(user, region, period, discussion = nil)
    @user, @period = user, period
    @region = region
    @featured_discussion = discussion

    @notifications = user.pending_notifications(@region, @period).where(
      type: GRAETZL_SUMMARY_BLOCKS.values.flatten.map(&:to_s)
    )

    if @notifications.empty?
      Rails.logger.info("[Graetzl Summary Mail] #{@user.email} #{@period}: None found")
      return
    else
      Rails.logger.info("[Graetzl Summary Mail] #{@user.email} #{@period}: #{@notifications.size} found")
    end

    headers(
      "X-MC-Tags" => "summary-graetzl-mail",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "summary-graetzl-mail",
    )

    mail(
      subject: "Neues #{t("region.#{@region.id}.from_graetzl")} #{@user.graetzl.name}", 
      from: platform_email('no-reply'),
      to: @user.email,
    )

    @notifications.update_all(sent: true)
  end

  PERSONAL_SUMMARY_BLOCKS = {
    'Neuer Kommentar auf deiner Pinnwand' => [
      Notifications::NewWallComment,
    ],
    "Änderungen an einem Treffen" => [
      Notifications::MeetingUpdated,
    ],
    "Neuer Kommentar bei" => [
      Notifications::CommentInMeeting, Notifications::ReplyOnComment,
    ],
    'Ebenfalls kommentiert' => [
      Notifications::CommentOnFollowedContent, Notifications::ReplyOnFollowedComment,
    ]
  }

  GROUP_SUMMARY_TYPES = [
    Notifications::NewGroupMeeting,
    Notifications::NewGroupDiscussion,
    Notifications::NewGroupPost,
    Notifications::CommentOnDiscussionPost,
    Notifications::ReplyOnFollowedDiscussionPost,
  ]

  def summary_personal(user, region, period)
    @user, @period = user, period
    @region = region

    @notifications = {}
    @notifications[:attendees] = user.pending_notifications(@region, @period).where(
      type: "Notifications::MeetingAttended"
    )
    @notifications[:personal] = user.pending_notifications(@region, @period).where(
      type: PERSONAL_SUMMARY_BLOCKS.values.flatten.map(&:to_s)
    )
    @notifications[:groups] = user.pending_notifications(@region, @period).where(
      type: GROUP_SUMMARY_TYPES.map(&:to_s)
    )

    if @notifications.values.all?(&:empty?)
      Rails.logger.info("[Personal Summary Mail] #{@user.email} #{@period}: None found")
      return
    else
      Rails.logger.info("[Personal Summary Mail] #{@user.email} #{@period}: #{@notifications.values.sum(&:size)} found")
    end

    headers(
      "X-MC-Tags" => "summary-personal-mail",
      "X-MC-GoogleAnalytics" => @region.host,
      "X-MC-GoogleAnalyticsCampaign" => "summary-personal-mail",
    )

    mail(
      subject: "Persönliche Neuigkeiten für #{@user.first_name} zusammengefasst",
      from: platform_email('no-reply'),
      to: @user.email,
    )

    @notifications.values.each { |n| n.update_all(sent: true) }
  end

  private

  def prepend_view_paths
    prepend_view_path 'app/views/mailers/notification_mailer'
  end

end
