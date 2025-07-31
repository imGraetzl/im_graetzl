module SchemaOrg
  class RoomDemand < Base
    
    def initialize(object, host:)
      super
      @room_demand = object
    end

    def to_schema
      hash = { "@type" => "Person" }
      hash["name"] = [@room_demand.first_name, @room_demand.last_name].compact.join(' ') if @room_demand.first_name || @room_demand.last_name
      hash["image"] = @room_demand.avatar_url.presence || asset_url('meta/og_logo.png')
      hash["description"] = @room_demand.personal_description if @room_demand.personal_description.present?
      hash["email"] = @room_demand.email if @room_demand.email.present?
      hash["telephone"] = @room_demand.phone if @room_demand.phone.present?
      hash["url"] = @room_demand.website if @room_demand.website.present?

      demand = { "@type" => "Demand" }
      item_offered = { "@type" => "Room" }

      item_offered["name"] = @room_demand.slogan if @room_demand.slogan.present?
      item_offered["description"] = @room_demand.demand_description if @room_demand.demand_description.present?

      if @room_demand.room_categories.present?
        item_offered["permittedUsage"] = @room_demand.room_categories.map(&:name).reject(&:blank?).uniq
      end

      if @room_demand.keyword_list.present?
        amenity_list = @room_demand.keyword_list.is_a?(String) ? @room_demand.keyword_list.split(',') : @room_demand.keyword_list
        item_offered["amenityFeature"] = amenity_list.map do |feat|
          { "@type" => "LocationFeatureSpecification", "name" => feat.strip }
        end
      end

      demand["itemOffered"] = item_offered if item_offered.size > 1
      hash["seeks"] = demand if demand["itemOffered"].present?

      hash.compact
    end
  end
end
