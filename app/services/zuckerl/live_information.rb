class Zuckerl::LiveInformation
  include Rails.application.routes.url_helpers
  MAIL_TEMPLATE = 'zuckerl-live'

  def initialize(zuckerl)
    @zuckerl = zuckerl
    @location = @zuckerl.location
    @user = @location.boss
  end

  def deliver
    message = build_message
    MandrillMessage.new(@user, template: MAIL_TEMPLATE, message: message).deliver
  end

  private

  attr_reader :zuckerl, :location, :user

  def build_message
    url_options = Rails.application.config.action_mailer.default_url_options
    {
      to: [ { email: @user.email } ],
      from_email: Rails.configuration.x.mandril_from_email,
      from_name: Rails.configuration.x.mandril_from_name,
      subject: 'Dein Grätzlzuckerl ist jetzt online',
      merge_vars: [
        rcpt: @user.email,
        vars: [
          { name: 'username', content: @user.username },
          { name: 'graetzl_name', content: @location.graetzl.name },
          { name: 'zuckerl_title', content: @zuckerl.title },
          { name: 'zuckerl_period', content: I18n.localize(@zuckerl.created_at.end_of_month+1.day, format: '%B %Y') },
          { name: 'zuckerl_url', content: user_zuckerls_url(url_options) },
          { name: 'graetzl_zuckerls_url', content: graetzl_zuckerls_url(@location.graetzl, url_options) },
          { name: 'location_zuckerl_url', content: graetzl_location_url(@location.graetzl, @location, url_options) },
        ]
      ]
    }
  end
end
