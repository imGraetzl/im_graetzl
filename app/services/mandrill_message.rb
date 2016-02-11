class MandrillMessage
  include Rails.application.routes.url_helpers

  def initialize(user, template: nil, message: nil)
    @user = user
    @template = template
    @message = message
    @template_content = []
  end

  def deliver
    if @message && @template
      mandrill_client.messages.send_template(
        @template,
        @template_content,
        @message)
    end
  end

  private

  attr_writer :message
  attr_reader :user, :template_content, :template

  def mandrill_client
    @mandrill_client ||= Mandrill::API.new MANDRILL_API_KEY
  end

  def default_url_options
    @default_url_options ||= Rails.application.config.action_mailer.default_url_options
  end

  def basic_message_vars
    [
      { name: "username", content: @user.username },
      { name: "edit_user_url", content: edit_user_url(default_url_options) },
      { name: "graetzl_name", content: @user.graetzl.name },
      { name: "graetzl_url", content: graetzl_url(@user.graetzl, default_url_options) }
    ]
  end
end
