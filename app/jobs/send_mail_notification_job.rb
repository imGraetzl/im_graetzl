class SendMailNotificationJob < ActiveJob::Base
  queue_as :default
  include Rails.application.routes.url_helpers

  def perform(user_id, interval, notification_id = nil)
    user = User.find user_id
    notifications = []
    case interval
    when "immediate"
      notifications = [ Notification.find(notification_id) ]
    when "daily"
      notifications = user.notifications_of_the_day
    when "weekly"
      notifications = user.notifications_of_the_week
    else
      notifications = []
    end
    template_name = "summary-notification"
    template_content = []
    default_url_options = Rails.application.config.action_mailer.default_url_options
    vars = [
      { name: "first_name", content: user.first_name},
      { name: "last_name", content: user.last_name},
    ]

    notification_vars = [ ]
    notifications.each do |notification|
      activity = PublicActivity::Activity.find notification.activity_id
      type = Notification::TYPES.select { |k,v| v[:bitmask] == notification.bitmask }.first[0].to_s
      case type
      when "new_meeting_in_graetzl"
        notification_vars << {
          "type": "new_meeting_in_graetzl",
          "meeting_name": activity.trackable.name,
          "created_by": activity.owner.username,
          "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
          "graetzl_name": activity.trackable.graetzl.name,
          "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "new_post_in_graetzl"
        notification_vars << {
          "type": "new_post_in_graetzl",
          "post_content": activity.trackable.content,
          "created_by": activity.owner.username,
          "post_url": graetzl_url(activity.trackable.graetzl, default_url_options) + "#post-#{activity.trackable.id}",
          "graetzl_name": activity.trackable.graetzl.name,
            "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "another_attendee"
        notification_vars << {
          "type": "another_attendee",
          "meeting_name": activity.trackable.name,
          "attendee": activity.owner.username,
          "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
          "graetzl_name": activity.trackable.graetzl.name,
          "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "attendee_left"
        notification_vars << {
          "type": "attendee_left",
          "meeting_name": activity.trackable.name,
          "attendee": activity.owner.username,
          "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
          "graetzl_name": activity.trackable.graetzl.name,
          "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "another_user_comments"
        notification_vars << {
          "type": "another_user_comments",
          "meeting_name": activity.trackable.name,
          "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
          "created_by": activity.owner.username,
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
            "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "user_comments_users_meeting"
        notification_vars << {
          "type": "user_comments_users_meeting",
          "meeting_name": activity.trackable.name,
          "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
          "created_by": activity.owner.username,
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
            "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "initiator_comments"
        notification_vars << {
          "type": "initiator_comments",
          "meeting_name": activity.trackable.name,
          "comment_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
          "created_by": activity.owner.username,
            "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
            "graetzl_name": activity.trackable.graetzl.name,
            "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "update_of_meeting"
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
          "created_by": activity.owner.username,
          "meeting_url": graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options),
          "graetzl_name": activity.trackable.graetzl.name,
          "graetzl_url": graetzl_url(activity.trackable.graetzl, default_url_options)
        }
      when "new_wall_comment"
        notification_vars << {
          "type": "new_wall_comment",
          "comment_url": graetzl_users_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}",
          "comment_content": activity.recipient.content,
          "created_by": activity.owner.username
        }
      end
    end

    message = {
      to: [ { email: user.email } ],
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
