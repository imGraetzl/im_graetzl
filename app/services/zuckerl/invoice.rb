class Zuckerl::Invoice
  MAIL_TEMPLATE = 'zuckerl-successfully-paid-and-invoice'

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
    {
      to: [ { email: @user.email } ],
      from_email: Rails.configuration.x.mandril_from_email,
      from_name: Rails.configuration.x.mandril_from_name,
      subject: 'Zuckerl booking...?',
      merge_vars: [
        rcpt: @user.email,
        vars: [
          { name: 'username', content: @user.username },
          { name: 'payment_reference', content: @zuckerl.payment_reference },
          { name: 'location_name', content: @location.name },
          { name: 'location_url', content: '#' },
          { name: 'zuckerl_url', content: '#' },
          { name: 'zuckerl_period', content: I18n.localize(@zuckerl.created_at, format: '%B %Y') },
          { name: 'billing_address', content: billing_address_vars },
        ]
      ]
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
