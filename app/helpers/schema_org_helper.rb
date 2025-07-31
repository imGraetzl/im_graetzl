module SchemaOrgHelper
  def schema_org_tag(object)
    return unless object.respond_to?(:to_schema)
    data = object.to_schema
    return unless data

    ordered_data = ActiveSupport::OrderedHash.new
    ordered_data["@context"] = "https://schema.org"
    data.each { |k, v| ordered_data[k] = v }
    content_tag(:script, ordered_data.to_json.html_safe, type: 'application/ld+json')
  end
end
