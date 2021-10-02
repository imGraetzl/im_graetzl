class DeviseMailer < Devise::Mailer
  include Devise::Mailers::Helpers

  def confirmation_instructions(user, token, opts = {})
    @region = user.region
    opts[:from] = platform_email('no-reply')
    super
  end

  def reset_password_instructions(user, token, opts = {})
    @region = user.region
    opts[:from] = platform_email('no-reply')
    super
  end

  def unlock_instructions(user, token, opts = {})
    @region = user.region
    opts[:from] = platform_email('no-reply')
    super
  end

  def email_changed(user, opts = {})
    @region = user.region
    opts[:from] = platform_email('no-reply')
    super
  end

  def password_change(user, opts = {})
    @region = user.region
    opts[:from] = platform_email('no-reply')
    super
  end

  private

  def platform_email(email_name, label_name = nil)
    label = [label_name, @region.platform_name].compact.join(' | ')
    email = "#{email_name}@#{@region.platform_domain}"
    email_address_with_name(email, label)
  end

end
