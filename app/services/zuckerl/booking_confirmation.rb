class Zuckerl::BookingConfirmation
  include Rails.application.routes.url_helpers
  MAIL_TEMPLATE = 'zuckerl-booking-confirmation'

  def initialize(zuckerl)
    @zuckerl = zuckerl
    @location = @zuckerl.location
    @user = @location.boss
  end

  def deliver
    message = build_message
    MandrillMailer.deliver template: MAIL_TEMPLATE, message: message
  end

  private

  attr_reader :zuckerl, :location, :user

  def build_message
    url_options = Rails.application.config.action_mailer.default_url_options
    {
      to: [ { email: @user.email } ],
      from_email: Rails.configuration.x.mandril_from_email,
      from_name: Rails.configuration.x.mandril_from_name,
      subject: 'Grätzlzuckerl Buchungsbestätigung & Infos zur Zahlung',
      merge_vars: [
        rcpt: @user.email,
        vars: [
          { name: 'username', content: @user.username },
          { name: 'zuckerl_start', content: I18n.localize(Time.now.end_of_month+1.day, format: '%d.%m.%Y') },
          { name: 'payment_reference', content: @zuckerl.payment_reference },
          { name: 'location_name', content: @location.name },
          { name: 'zuckerl_url', content: user_zuckerls_url(url_options) }
        ]
      ]
    }
  end
end
