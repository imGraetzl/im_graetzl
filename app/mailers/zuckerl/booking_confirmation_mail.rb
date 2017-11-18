class Zuckerl::BookingConfirmationMail < Zuckerl::BaseMail
  MAIL_TEMPLATE = 'zuckerl-booking-confirmation'
  SUBJECT = 'Grätzlzuckerl Buchungsbestätigung & Infos zur Zahlung'

  private

  def template
    MAIL_TEMPLATE
  end

  def message
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
      { name: 'zuckerl_start', content: start_time },
      { name: 'payment_reference', content: @zuckerl.payment_reference },
      { name: 'location_name', content: @location.name },
      { name: 'zuckerl_url', content: zuckerls_user_url(URL_OPTIONS) }
    ]
  end

  def start_time
    I18n.localize Time.now.end_of_month+1.day, format: '%d.%m.%Y'
  end
end
