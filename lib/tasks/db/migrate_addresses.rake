namespace :db do

  desc 'connect districts and graetzls using geometry'
  task migrate_addresses: :environment do
    [User, Meeting, Location, RoomOffer, RoomCall, ToolOffer].each do |model_class|
      model_class.find_each do |object|
        print "#{model_class} #{object.id}\n"
        address = AddressLegacy.find_by(addressable_type: model_class.name, addressable_id: object.id)
        next if address.nil?
        object.update_columns(
          address_street: address.street&.strip,
          address_zip: address.zip,
          address_city: address.city,
          address_coordinates: address.coordinates,
          address_description: address.description,
        )
      end

      Location.find_each do |object|
        next if object.contact.nil?
        object.update_columns(
          website_url: object.contact.website,
          online_shop_url: object.contact.online_shop,
          email: object.contact.email,
          phone: object.contact.phone,
          open_hours: object.contact.hours,
        )
      end
    end

  end
end
