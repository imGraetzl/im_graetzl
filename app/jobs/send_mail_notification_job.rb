class SendMailNotificationJob < ActiveJob::Base
  queue_as :default
  include Rails.application.routes.url_helpers

  def perform(user_id, interval, notification_id = nil)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find user_id
      notifications = []
      template_name = nil
      subject = nil
      case interval
      when "immediate"
        notifications = [ Notification.find(notification_id) ]
        #template_name = "summary-notification"
      when "daily"
        notifications = user.notifications_of_the_day
        template_name = "weekly-daily-mandrill-notifications"
      when "weekly"
        notifications = user.notifications_of_the_week
        template_name = "weekly-daily-mandrill-notifications"
      else
        notifications = []
        #template_name ||= "notification-#{type}"
        #template_name = "summary-notification-dev"
      end
      return if notifications.empty?
      template_content = []
      default_url_options = Rails.application.config.action_mailer.default_url_options
      vars = [
        { name: "username", content: user.username },
        { name: "edit_user_url", content: edit_user_url(default_url_options) },
        { name: "first_name", content: user.first_name},
        { name: "last_name", content: user.last_name},
        { name: "graetzl_name", content: user.graetzl.name },
        { name: "graetzl_url", content: graetzl_url(user.graetzl, default_url_options) },
        { name: "interval", content: interval }
      ]

      notification_vars = [ ]
      message_vars = [ ]
      notifications.each do |notification|
        activity = PublicActivity::Activity.find notification.activity_id
        type = Notification::TYPES.select { |k,v| v[:bitmask] == notification.bitmask }.first[0].to_s
        template_name ||= "notification-#{type.gsub(/_/, '-')}"
        case type
        when "new_meeting_in_graetzl"
          subject = "Neues Treffen im #{activity.trackable.graetzl.name}"
          notification_vars << {
            "type": "new_meeting_in_graetzl",
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_name": activity.trackable.name,
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "meeting_starts_at_date": activity.trackable.starts_at_date ? I18n.localize(activity.trackable.starts_at_date, format:'%A %d. %B') : '',
            "meeting_starts_at_time": activity.trackable.starts_at_time ? I18n.localize(activity.trackable.starts_at_time, format:'%H:%M') : '',
            "meeting_description": activity.trackable.description.truncate(300, separator: ' ')
          }
        when "new_post_in_graetzl"
          subject = "Neuer Beitrag im #{activity.trackable.graetzl.name}"
          notification_vars << {
            "type": "new_post_in_graetzl",
            "post_content": activity.trackable.content.truncate(300, separator: ' '),
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "post_url": graetzl_post_url(activity.trackable.graetzl, activity.trackable, default_url_options)
          }
        when "another_attendee"
          subject = 'Neuer Teilnehmer an deinem Treffen'
          notification_vars << {
            "type": "another_attendee",
            "meeting_name": activity.trackable.name,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name
          }
        when "attendee_left"
          subject = 'Absage eines Teilnehmers an deinem Treffen'
          notification_vars << {
            "type": "attendee_left",
            "meeting_name": activity.trackable.name,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
          }
        when "another_user_comments"
          subject = 'Neuer Kommentar in einem Treffen'
          notification_vars << {
            "type": "another_user_comments",
            "meeting_name": activity.trackable.name,
            "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name
          }
        when "user_comments_users_meeting"
          subject = 'Neuer Kommentar in deinem Treffen'
          notification_vars << {
            "type": "user_comments_users_meeting",
            "meeting_name": activity.trackable.name,
            "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
          }
        when "initiator_comments"
          subject = "Neues Treffen im #{activity.trackable.graetzl.name}"
          template_name ||= 'summary-notification-dev'
          notification_vars << {
            "type": "initiator_comments",
            "meeting_name": activity.trackable.name,
            "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
            "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
          }
        when "update_of_meeting"
          subject = "Neues Treffen im #{activity.trackable.graetzl.name}"
          template_name ||= 'summary-notification-dev'
          translation = {
            :address => "Ort",
            :adress_attributes => "Ort",
            :starts_at_date => "Datum",
            :ends_at_date => "Datum",
            :starts_at_time => "Uhrzeit",
            :ends_at_time => nil,
            :description => "Beschreibung"
          }

          translated_changes = activity.parameters[:changed_attributes].collect { |a| translation[a] }.uniq.compact
          notification_vars << {
            "type": "update_of_meeting",
            "changes": translated_changes.to_sentence(two_words_connector: " und ", last_word_connector: ", und "),
            "meeting_name": activity.trackable.name,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
            "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
          }
        when "new_wall_comment"
          subject = "Neues Treffen im #{activity.trackable.graetzl.name}"
          template_name ||= 'summary-notification-dev'
          notification_vars << {
            "type": "new_wall_comment",
            "comment_url": graetzl_user_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options)
          }
        when "cancel_of_meeting"
          subject = "Neues Treffen im #{activity.trackable.graetzl.name}"
          template_name ||= 'summary-notification-dev'
          notification_vars << {
            "type": "cancel_of_meeting",
            "meeting_name": activity.trackable.name,
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "meeting_url": activity.recipient.content,
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options)
          }
        when "approve_of_location"
          subject = "Neues Treffen im #{activity.trackable.graetzl.name}"
          template_name ||= 'summary-notification-dev'
          notification_vars << {
            "type": "approve_of_location",
            "location_name": activity.trackable.name,
            "location_url": graetzl_location_url(activity.trackable.graetzl, activity.trackable, default_url_options),
          }
        end
      end

      message = {
        to: [ { email: user.email } ],
        from_email: Rails.configuration.x.mandril_from_email,
        from_name: Rails.configuration.x.mandril_from_name,
        subject: subject,
        merge_vars: [
          rcpt: user.email,
          vars: vars + [
            { name: "notifications", content: notification_vars }
          ]
        ]
      }

      Mandrill::API.new(MANDRILL_API_KEY).messages.send_template(
        template_name,
        template_content,
        message
      )
    end
  end
end
