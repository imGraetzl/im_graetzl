class SendMailNotificationJob < ActiveJob::Base
  queue_as :default
  include Rails.application.routes.url_helpers

  def perform(user_id, activity_id, type)
    user = User.find user_id
    activity = PublicActivity::Activity.find activity_id
    template_name = "immediate-notification-#{type.to_s.gsub(/_/,'-')}"
    template_content = []
    default_url_options = Rails.application.config.action_mailer.default_url_options
    message = {
      to: [ { email: user.email } ],
      merge_vars: [
        rcpt: user.email,
        vars: [
          { name: "first_name", content: user.first_name},
          { name: "last_name", content: user.last_name},
          { name: "meeting_name", content: activity.trackable.name },
          { name: "created_by", content: activity.owner.username},
          { name: "meeting_url", content: graetzl_meeting_url(activity.trackable.graetzl, activity.trackable, default_url_options) },
          { name: "graetzl_name", content: activity.trackable.graetzl.name},
          {name: "graetzl_url", content: graetzl_url(activity.trackable.graetzl, default_url_options) }
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
