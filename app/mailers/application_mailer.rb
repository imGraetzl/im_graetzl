class ApplicationMailer < ActionMailer::Base
  layout 'mailer'
  helper :image

  def self.inherited(subclass)
    subclass.default template_path: "mailers/#{subclass.name.to_s.underscore}"
  end

  def default_url_options
    Rails.application.default_url_options.merge(host: @region.host)
  end

  def platform_email(email_name, label_name = nil)
    label = [label_name, @region.platform_name].compact.join(' | ')
    email = "#{email_name}@#{@region.domain}"
    email_address_with_name(email, label)
  end

end
