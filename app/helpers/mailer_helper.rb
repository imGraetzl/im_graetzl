module MailerHelper

  def mail_image_tag(source, options = {})
    # We can't set dynamic asset host config for mailers
    # so we set host for our server-hosted images.
    if Rails.env.staging? || Rails.env.production?
      source = image_url(source, host: "https://#{@region.host}")
    end
    image_tag(source, options)
  end

end