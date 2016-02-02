class Notifications::MandrillMessage
  include Rails.application.routes.url_helpers

  # attr_reader :template_name, :template_content, :message

  def initialize(user)
    @user = user
    @default_url_options = Rails.application.config.action_mailer.default_url_options
    @template_content = []
    @message = {}
  end

  def basic_message_vars
    [
      { name: "username", content: @user.username },
      { name: "edit_user_url", content: edit_user_url(@default_url_options) },
      { name: "graetzl_name", content: @user.graetzl.name },
      { name: "graetzl_url", content: graetzl_url(@user.graetzl, @default_url_options) }
    ]
  end

  def deliver
    mandrill_client.messages.send_template(
      @template_name,
      @template_content,
      @message
    )
  end

  private

  attr_accessor :message

  def mandrill_client
    @mandrill_client ||= Mandrill::API.new MANDRILL_API_KEY
  end
end
