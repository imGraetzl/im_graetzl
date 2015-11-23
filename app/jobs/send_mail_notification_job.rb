# class SendMailNotificationJob < ActiveJob::Base
#   queue_as :default
class SendMailNotificationJob
  include SuckerPunch::Job
  include Rails.application.routes.url_helpers

  def perform(user_id, interval, notification_id = nil)
    SuckerPunch.logger.info ('Perform SendMailNotificationJob')
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find user_id
      notifications = []
      template_name = nil
      subject = nil
      case interval
      when "immediate"
        notifications = [ Notification.find(notification_id) ]
      when "daily"
        notifications = user.notifications_of_the_day
        template_name = "weekly-daily-mandrill-notifications"
      when "weekly"
        notifications = user.notifications_of_the_week
        template_name = "weekly-daily-mandrill-notifications"
      else
        notifications = []
        template_name = "summary-notification"
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
        #activity = PublicActivity::Activity.find notification.activity_id
        activity = notification.activity
        type = Notification::TYPES.select { |k,v| v[:bitmask] == notification.bitmask }.first[0].to_s
        template_name ||= "notification-#{type.gsub(/_/, '-')}"
        case type
        when "new_meeting_in_graetzl"
          subject = "Neues Treffen im Grätzl #{activity.trackable.graetzl.name}"
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
          subject = "Neuer Beitrag im Grätzl #{activity.trackable.graetzl.name}"
          author = activity.trackable.author
          if author.is_a?(User)
            notification_vars << {
              "post_content": activity.trackable.content.truncate(300, separator: ' '),
              "owner_name": author.username,
              "owner_url": user_url(activity.owner, default_url_options),
              "post_url": graetzl_post_url(activity.trackable.graetzl, activity.trackable, default_url_options)
            }
          else
            notification_vars << {
              "post_content": activity.trackable.title,
              "owner_name": author.name,
              "owner_url": graetzl_location_url([author.graetzl, author], default_url_options),
              "post_url": url_for([author.graetzl, author], default_url_options),
            }
          end
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
          subject = 'Ein Treffen an dem du teilnimmst wurde kommentiert'
          notification_vars << {
            "type": "another_user_comments",
            "meeting_name": activity.trackable.name,
            "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content.truncate(300, separator: ' '),
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name
          }
        when "user_comments_users_meeting"
          subject = 'Dein Treffen wurde kommentiert'
          notification_vars << {
            "type": "user_comments_users_meeting",
            "meeting_name": activity.trackable.name,
            "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content.truncate(300, separator: ' '),
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
          }
        when "initiator_comments"
          subject = 'Ein Treffen an dem du teilnimmst wurde vom Veranstalter kommentiert'
          notification_vars << {
            "type": "initiator_comments",
            "meeting_name": activity.trackable.name,
            "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content.truncate(300, separator: ' '),
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
          }
        when "update_of_meeting"
          subject = 'Es gibt Änderungen in einem Treffen an dem du teilnimmst'
          translation = {
            :address => "Ort",
            :adress_attributes => "Ort",
            :starts_at_date => "Datum",
            :starts_at_time => "Uhrzeit",
            :ends_at_time => "Uhrzeit",
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
          }
        when "new_wall_comment"
          subject = 'Neuer Kommentar auf deiner Pinnwand'
          notification_vars << {
            "type": "new_wall_comment",
            "comment_url": graetzl_user_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
            "comment_content": activity.recipient.content.truncate(300, separator: ' '),
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options)
          }
        when "cancel_of_meeting"
          subject = 'Absage eines Treffens an dem du teilnimmst'
          notification_vars << {
            "type": "cancel_of_meeting",
            "meeting_name": activity.trackable.name,
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "owner_name": activity.owner.username,
            "owner_url": user_url(activity.owner, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name
          }
        when "approve_of_location"
          subject = 'Deine Location wurde geprüft'
          notification_vars << {
            "type": "approve_of_location",
            "location_name": activity.trackable.name,
            "location_url": graetzl_location_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name
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
