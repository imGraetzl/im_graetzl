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

    Rails.logger.info("[Immediate Mail] [#{@user.id}] [#{@user.email}]: #{@notification.mail_subject}")

    begin
      mail(
        subject: @notification.mail_subject,
        from: platform_email('no-reply'),
        to: @user.email,
        template_name: "immediate/#{@notification.mail_template}"
      )

      @notification.update_columns(sent: true)

    rescue StandardError => e
      Rails.logger.error("[Immediate Mail] Error sending immediate mail to #{@user.email}: #{e.message}")
    end

  end

  GRAETZL_SUMMARY_BLOCKS = {
    'Neue Crowdfunding Kampagnen wurden gestartet' => [
      Notifications::NewCrowdCampaign
    ],
    'Neue Schaufenster' => [
      Notifications::NewLocation
    ],
    'Diese Crowdfunding Kampagnen enden bald!' => [
      Notifications::EndingCrowdCampaign
    ],
    'Neue Räume zum Andocken' => [
      Notifications::NewRoomOffer
    ],
    'Auf der Suche nach Raum' => [
      Notifications::NewRoomDemand
    ],
    'Neue Energiegemeinschaften zum Andocken' => [
      Notifications::NewEnergyOffer
    ],
    'Auf der Suche nach einer Energiegemeinschaft' => [
      Notifications::NewEnergyDemand
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
  }

  def summary_graetzl(user, region_id, period)
    begin
      @user, @period = user, period
      @region = Region.get(region_id)

      @notifications = user.pending_notifications(@region, @period).where(
        type: GRAETZL_SUMMARY_BLOCKS.values.flatten.map(&:to_s)
      )

      if @notifications.empty?
        Rails.logger.info("[#{@period} Graetzl Summary Mail] [#{@user.id}] [#{@region.id}] [#{@user.email}]: None found")
        return
      else
        Rails.logger.info("[#{@period} Graetzl Summary Mail] [#{@user.id}] [#{@region.id}] [#{@user.email}]: Found: #{@notifications.size}")
        @zuckerls = Zuckerl.in(@region).live.include_for_box
        @subscriptions = Subscription.in(@region).active
        # @good_morning_dates = Meeting.in(@region).good_morning_dates.upcoming
      end

      headers(
        "X-MC-Tags" => "summary-graetzl-#{@region.id}",
        "X-MC-GoogleAnalytics" => @region.host,
        "X-MC-GoogleAnalyticsCampaign" => "summary-graetzl-mail",
      )

      mail(
        subject: t("region.#{@region.id}.mailers.summary_graetzl.subject", graetzl: @user.graetzl.name), 
        from: platform_email('no-reply'),
        to: @user.email,
      )

      @notifications.update_all(sent: true)

    rescue Net::OpenTimeout => e
      Rails.logger.warn "[OpenTimeout Graetzl Summary Mail] #{@user&.email}: #{e.message}"
      raise e  # explizit reraisen, damit delayed_job retryen kann
    rescue Errno::ECONNRESET => e
      Rails.logger.warn "[ECONNRESET Graetzl Summary Mail] #{@user&.email}: #{e.message}"
      # kein raise, da Mail wahrscheinlich trotzdem rausging
      return
    rescue => e
      Rails.logger.error "[Error Graetzl Summary Mail]: #{@user&.email}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end

  PERSONAL_SUMMARY_BLOCKS = {
    'Neuer Kommentar bei deiner Crowdfunding Kampagne' => [
      Notifications::CommentOnCrowdCampaign,
    ],
    'Neuer Kommentar auf deiner Pinnwand' => [
      Notifications::NewWallComment,
    ],
    "Änderungen an einem Treffen" => [
      Notifications::MeetingUpdated,
    ],
    "Neuer Kommentar bei einem Treffen an dem du teilnimmst" => [
      Notifications::CommentInAttending,
    ],
    "Neuer Kommentar bei deinen erstellten Inhalten" => [
      Notifications::CommentOnOwnedContent,
    ],
    "Neue Antworten auf dein Kommentar" => [
      Notifications::ReplyOnComment,
    ],
    'Ebenfalls kommentiert' => [
      Notifications::CommentOnFollowedContent, Notifications::ReplyOnFollowedComment,
    ]
  }

  GROUP_SUMMARY_TYPES = [
    Notifications::NewGroupDiscussion,
    Notifications::NewGroupPost,
    Notifications::CommentOnDiscussionPost,
    Notifications::ReplyOnFollowedDiscussionPost,
  ]

  def summary_personal(user, region_id, period)
    begin
      @user, @period = user, period
      @region = Region.get(region_id)

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
        Rails.logger.info("[#{@period} Personal Summary Mail] [#{@region.id}] [#{@user.id}] [#{@user.email}]: None found")
        return
      else
        Rails.logger.info("[#{@period} Personal Summary Mail] [#{@region.id}] [#{@user.id}] [#{@user.email}]: Found: #{@notifications.values.sum(&:size)}")
      end

      headers(
        "X-MC-Tags" => "summary-personal-#{@region.id}",
        "X-MC-GoogleAnalytics" => @region.host,
        "X-MC-GoogleAnalyticsCampaign" => "summary-personal-mail",
      )

      mail(
        subject: "Persönliche Neuigkeiten für #{@user.first_name} zusammengefasst",
        from: platform_email('no-reply'),
        to: @user.email,
      )

      @notifications.values.each { |n| n.update_all(sent: true) }

    rescue Net::OpenTimeout => e
      Rails.logger.warn "[OpenTimeout Personal Summary Mail] #{@user&.email}: #{e.message}"
      raise e  # explizit reraisen, damit delayed_job retryen kann
    rescue Errno::ECONNRESET => e
      Rails.logger.warn "[ECONNRESET Personal Summary Mail] #{@user&.email}: #{e.message}"
      # kein raise, da Mail wahrscheinlich trotzdem rausging
      return
    rescue => e
      Rails.logger.error "[Error Personal Summary Mail]: #{@user&.email}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end

  private

  def prepend_view_paths
    prepend_view_path 'app/views/mailers/notification_mailer'
  end

end
