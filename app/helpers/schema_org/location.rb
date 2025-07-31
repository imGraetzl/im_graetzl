module SchemaOrg
  class Location < Base

    def initialize(object, host:)
      super
      @location = object
    end

    def to_schema
      hash = { "@type" => "LocalBusiness" }
      hash["@id"] = graetzl_location_url(@location.graetzl, @location, host: @host)
      hash["url"] = graetzl_location_url(@location.graetzl, @location, host: @host)
      hash["name"] = @location.name if @location.name.present?
      hash["slogan"] = @location.slogan if @location.slogan.present?
      hash["description"] = strip_tags(@location.description).truncate(300) if @location.description.present?
      hash["email"] = @location.email if @location.email.present?
      hash["telephone"] = @location.phone if @location.phone.present?
      hash["founder"] = schema_org_person_reference(@location.user, host: @host) if @location.user
      hash["address"] = schema_org_address(@location) if @location.using_address?
      hash["geo"] = schema_org_geo(@location) if @location.address_coordinates.present?
      hash["logo"] = @location.avatar_url.presence || asset_url('fallbacks/location_avatar.png')
      hash["image"] = schema_org_images(@location, placeholder: asset_url('meta/og_logo.png'), limit: 5)

      keywords = []
      keywords << @location.location_category&.name if @location.location_category&.name.present?
      keywords += @location.products.pluck(:name) if @location.products.present?
      keywords = keywords.compact.reject(&:blank?).uniq
      hash["keywords"] = keywords.join(", ") if keywords.any?

      if @location.upcoming_meetings.any?
        hash["event"] = @location.upcoming_meetings
                              .where.not(starts_at_date: nil)
                              .order(:starts_at_date, :starts_at_time)
                              .limit(5)
                              .map { |meeting| schema_org_meeting_reference(meeting, host: @host) }
      end

      same_as = []
      same_as << @location.website_url if @location.website_url.present?
      same_as << @location.online_shop_url if @location.online_shop_url.present?
      same_as = same_as.compact.reject(&:blank?).uniq
      hash["sameAs"] = same_as if same_as.any?

      hash.compact
    end
  end
end
