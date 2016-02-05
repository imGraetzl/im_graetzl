class Notifications::ImmediateMail < Notifications::MandrillMessage

  def initialize(notification)
    @notification = notification
    super(@notification.user)
    @template_name = @notification.mail_template
  end

  def deliver
    @message = build_message
    super
  end

  private

  attr_reader :notification

  def build_message
    {
      to: [ { email: @notification.user.email } ],
      from_email: Rails.configuration.x.mandril_from_email,
      from_name: Rails.configuration.x.mandril_from_name,
      subject: @notification.mail_subject,
      global_merge_vars: basic_message_vars,
      merge_vars: [
        rcpt: @notification.user.email,
        vars: @notification.basic_mail_vars + [
          { name: 'notification', content: @notification.mail_vars }
        ]
      ]
    }
  end
end
