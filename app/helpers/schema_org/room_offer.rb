module SchemaOrg
  class RoomOffer < Base

    def initialize(object, host:)
      super
      @room_offer = object
    end

    def to_schema
      hash = {
        "@type" => "Offer",
        "@id" => room_offer_url(@room_offer, host: @host),
        "url" => room_offer_url(@room_offer, host: @host),
        "name" => clean_for_schema(@room_offer.slogan.presence || "Raum zu vermieten"),
        "availability" => "https://schema.org/InStock",
        "businessFunction" => "http://purl.org/goodrelations/v1#LeaseOut",
        "image" => schema_org_images(@room_offer, placeholder: asset_url('meta/og_logo.png'), limit: 5),
        "potentialAction" => potential_action,
        "priceSpecification" => price_specs,
        "itemOffered" => room_schema,
        "seller" => seller_schema
      }
      if @room_offer.room_description.present?
        hash["description"] = clean_for_schema(strip_tags(@room_offer.room_description.bbcode_to_html).truncate(300))
      end
      hash.compact
    end

    private

    def potential_action
      if @room_offer.rental_enabled?
        {
          "@type" => "ReserveAction",
          "target" => "#{room_offer_url(@room_offer, host: @host)}#booking-box"
        }
      end
    end

    def price_specs
      specs = []
      if @room_offer.room_offer_prices.present?
        @room_offer.room_offer_prices.order(:amount).each do |price|
          next unless price.amount.present?
          specs << {
            "@type" => "UnitPriceSpecification",
            "name" => price.name.presence || "Preisangebot",
            "price" => price.amount.to_s,
            "priceCurrency" => "EUR"
          }
        end
      end
      if @room_offer.rental_enabled? && @room_offer.respond_to?(:room_rental_price) && @room_offer.room_rental_price
        rental = @room_offer.room_rental_price
        if rental.price_per_hour.present?
          specs << {
            "@type" => "UnitPriceSpecification",
            "name" => "Stundentarif",
            "price" => rental.price_per_hour.to_s,
            "priceCurrency" => "EUR",
            "unitText" => "HOUR",
            "eligibleQuantity" => {
              "@type" => "QuantitativeValue",
              "unitCode" => "HUR",
              "value" => 1
            }
          }
        end
        if rental.daily_price.present?
          desc = "Tagestarif (8 Stunden)"
          desc += ", #{rental.eight_hour_discount}% Rabatt" if rental.eight_hour_discount.present? && rental.eight_hour_discount.to_i > 0
          specs << {
            "@type" => "UnitPriceSpecification",
            "name" => desc,
            "price" => rental.daily_price.to_s,
            "priceCurrency" => "EUR",
            "unitText" => "DAY",
            "eligibleQuantity" => {
              "@type" => "QuantitativeValue",
              "unitCode" => "DAY",
              "value" => 1
            }
          }
        end
      end
      specs = specs.sort_by { |s| s["price"].to_f } if specs.any?
      specs
    end

    def room_schema
      room = {
        "@type" => "Room",
        "name" => @room_offer.slogan.presence || "Raum zu vermieten",
        "image" => schema_org_images(@room_offer, placeholder: asset_url('meta/og_logo.png'), limit: 5),
        "address" => schema_org_address(@room_offer)
      }

      if @room_offer.address_coordinates.present?
        room["geo"] = schema_org_geo(@room_offer)
      end

      if @room_offer.room_description.present?
        room["description"] = strip_tags(@room_offer.room_description.bbcode_to_html).truncate(200)
      end

      # Ausstattung
      if @room_offer.keyword_list.present?
        room["amenityFeature"] = @room_offer.keyword_list.map do |keyword|
          { "@type" => "LocationFeatureSpecification", "name" => keyword }
        end
      end

      # Categories als permittedUsage
      if @room_offer.room_categories.present?
        usages = @room_offer.room_categories.map(&:name).reject(&:blank?).uniq
        room["permittedUsage"] = usages if usages.any?
      end
      
      # OpeningHoursSpecification
      if @room_offer.room_offer_availability.present?
        availability = @room_offer.room_offer_availability
        opening_hours_spec = []
        days_mapping = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
        (0..6).each do |day_index|
          from_hour = availability.send("day_#{day_index}_from")
          to_hour = availability.send("day_#{day_index}_to")
          if from_hour.present? && to_hour.present?
            opening_hours_spec << {
              '@type' => 'OpeningHoursSpecification',
              'dayOfWeek' => "https://schema.org/#{days_mapping[day_index]}",
              'opens' => sprintf('%02d:00', from_hour),
              'closes' => sprintf('%02d:00', to_hour)
            }
          end
        end
        room["openingHoursSpecification"] = opening_hours_spec if opening_hours_spec.any?
      end
      room.compact
    end

    def seller_schema
      if @room_offer.location.present?
        schema_org_location_reference(@room_offer.location, host: @host)
      elsif @room_offer.user.present?
        schema_org_person_reference(@room_offer.user, host: @host)
      end
    end
  end
end
