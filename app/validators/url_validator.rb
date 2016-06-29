class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    add_error(record, attribute) unless valid_url?(value)
  end

  private

  def valid_url?(url)
    url = URI.parse url
    url.kind_of?(URI::HTTP) || URI.kind_of?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end

  def add_error(record, attribute)
    errors = record.errors
    errors.add attribute, :bad_url
  end
end
