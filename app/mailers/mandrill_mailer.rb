class MandrillMailer < BaseApiMailer
  FROM_EMAIL = Rails.configuration.x.mandril_from_email
  FROM_NAME = Rails.configuration.x.mandril_from_name

  def initialize(template:nil, message:nil)
    @template = template
    @message = message
  end

  def deliver
    send_mail if @template && @message
  end

  private

  attr_reader :template, :message

  def mandrill_client
    @mandrill_client ||= Mandrill::API.new MANDRILL_API_KEY
  end

  def send_mail
    mandrill_client.messages.send_template @template, [], @message
  end
end
