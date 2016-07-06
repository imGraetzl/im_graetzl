class Zuckerl::LiveInformation < MandrillMailer
  MAIL_TEMPLATE = 'zuckerl-live'
  SUBJECT = 'Dein Grätzlzuckerl ist jetzt online'

  def initialize(zuckerl)
    @zuckerl = zuckerl
    @location = zuckerl.location
    @user = @location.boss
    super template: MAIL_TEMPLATE, message: build_message
  end

  private

  attr_reader :zuckerl, :location, :user

  def build_message
    {
      to: [ { email: @user.email } ],
      from_email: FROM_EMAIL,
      from_name: FROM_NAME,
      subject: SUBJECT,
      merge_vars: [rcpt: @user.email, vars: message_vars]
    }
  end

  def message_vars
    [
      { name: 'username', content: @user.username },
      { name: 'graetzl_name', content: @location.graetzl.name },
      { name: 'zuckerl_title', content: @zuckerl.title },
      { name: 'zuckerl_period', content: start_time },
      { name: 'zuckerl_url', content: user_zuckerls_url(URL_OPTIONS) },
      { name: 'graetzl_zuckerls_url', content: graetzl_zuckerls_url(@location.graetzl, URL_OPTIONS) },
      { name: 'location_zuckerl_url', content: graetzl_location_url(@location.graetzl, @location, URL_OPTIONS) },
    ]
  end

  def start_time
    I18n.localize Date.today, format: '%B %Y'
  end
end
