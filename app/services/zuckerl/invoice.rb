class Zuckerl::Invoice
  include Rails.application.routes.url_helpers
  MAIL_TEMPLATE = 'zuckerl-successfully-paid-and-invoice'

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
      subject: 'Zahlungsbestätigung deines Grätzlzuckerls',
      merge_vars: [
        rcpt: @user.email,
        vars: [
          { name: 'username', content: @user.username },
          { name: 'payment_reference', content: @zuckerl.payment_reference },
          { name: 'payment_date', content: Date.today.strftime('%d.%m.%Y') },
          { name: 'location_name', content: @location.name },
          { name: 'location_url', content: graetzl_location_url(@location.graetzl, @location, url_options) },
          { name: 'zuckerl_url', content: user_zuckerls_url(url_options) },
          { name: 'zuckerl_period', content: I18n.localize(@zuckerl.created_at.end_of_month+1.day, format: '%B %Y') },
          { name: 'billing_address', content: billing_address_vars },
        ]
      ],
      bcc_address: 'rechnung@imgraetzl.at'
    }
  end

  def billing_address_vars
    if billing_address = @location.billing_address
      {
        first_name: billing_address.first_name,
        last_name: billing_address.last_name,
        company: billing_address.company,
        street: billing_address.street,
        zip: billing_address.zip,
        city: billing_address.city,
        country: billing_address.country
      }
    else
      nil
    end
  end
end
