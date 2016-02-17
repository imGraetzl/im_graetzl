class Zuckerl::LiveInformation
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
    {
      to: [ { email: @user.email } ],
      from_email: Rails.configuration.x.mandril_from_email,
      from_name: Rails.configuration.x.mandril_from_name,
      subject: 'Zuckerl booking...?',
      merge_vars: [
        rcpt: @user.email,
        vars: [
          { name: 'username', content: @user.username },
          { name: 'zuckerl_title', content: @zuckerl.title },
          { name: 'zuckerl_period', content: I18n.localize(@zuckerl.created_at.end_of_month+1.day, format: '%B %Y') },
          { name: 'zuckerl_url', content: '#' },
          { name: 'district_zuckerl_url', content: '#' },
          { name: 'location_zuckerl_url', content: '#' },
        ]
      ]
    }
  end
end
