class SendMailNotificationJob < ActiveJob::Base
  queue_as :default
  include Rails.application.routes.url_helpers

  def perform(user_id, activity_id, type)
    user = User.find user_id
    activity = PublicActivity::Activity.find activity_id
    template_name = "immediate-notification"
    template_content = []
    default_url_options = Rails.application.config.action_mailer.default_url_options
    vars = [
      { name: "first_name", content: user.first_name},
      { name: "last_name", content: user.last_name},
      { name: "notification_type", content: type.to_s},
    ]

    case type
    when "new_meeting_in_graetzl"
      vars += [
        { name: "meeting_name", content: activity.trackable.name },
        { name: "created_by", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    when "new_post_in_graetzl"
      vars += [
        { name: "post_content", content: activity.trackable.content },
        { name: "created_by", content: activity.owner.username},
        { name: "post_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) + "#post-#{activity.trackable.id}"},
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        { name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    when "another_attendee"
      vars += [
        { name: "meeting_name", content: activity.trackable.name },
        { name: "attendee", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    when "attendee_left"
      vars += [
        { name: "meeting_name", content: activity.trackable.name },
        { name: "attendee", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    when "another_user_comments"
      vars += [
        { name: "meeting_name", content: activity.trackable.name },
        { name: "comment_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}" },
        { name: "created_by", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    when "user_comments_users_meeting"
      vars += [
        { name: "meeting_name", content: activity.trackable.name },
        { name: "comment_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}" },
        { name: "created_by", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    when "initiator_comments"
      vars += [
        { name: "meeting_name", content: activity.trackable.name },
        { name: "comment_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) + "#comment-#{activity.recipient.id}" },
        { name: "created_by", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
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
      vars += [
        { name: "changes", content: translated_changes.to_sentence(two_words_connector: " und ", last_word_connector: ", und ") },
        { name: "meeting_name", content: activity.trackable.name },
        { name: "created_by", content: activity.owner.username},
        { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
        { name: "graetzl_name", content: activity.trackable.graetzl.name},
        {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
      ]
    end

    message = {
      to: [ { email: user.email } ],
      merge_vars: [
        rcpt: user.email,
        vars: vars
      ]
    }

    Mandrill::API.new(MANDRILL_API_KEY).messages.send_template(
      template_name,
      template_content,
      message
    )
  end
end
