class Zuckerl::BookingConfirmation
  MAIL_TEMPLATE = 'zuckerl-booking-confirmation'

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
          { name: 'zuckerl_start', content: I18n.localize(@zuckerl.created_at, format: '%d.%m.%Y') },
          { name: 'payment_reference', content: @zuckerl.payment_reference },
          { name: 'location_name', content: @location.name },
          { name: 'zuckerl_url', content: '#' }
        ]
      ]
    }
  end
end
