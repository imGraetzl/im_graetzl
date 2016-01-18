class Notifications::ImmediateMail < Notifications::MandrillMessage

  def initialize(notification)
    @notification = notification
    super(@notification.user)
    @message = build_message
    @template_name = @notification.mail_template
  end

  def build_message
    {
      to: [ { email: @user.email } ],
      from_email: Rails.configuration.x.mandril_from_email,
      from_name: Rails.configuration.x.mandril_from_name,
      subject: @notification.mail_subject,
      merge_vars: [
        rcpt: @user.email,
        vars: basic_message_vars + [
          { name: 'notification', content: @notification.mail_vars }
        ]
      ]
    }
  end
end
