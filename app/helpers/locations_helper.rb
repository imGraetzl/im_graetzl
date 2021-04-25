module LocationsHelper
  def location_meta(location)
    address = location.address
    desc = ''
    if address
      desc << "#{address.street_name} #{address.street_number.split(%r{/}).first}, #{address.zip} #{address.city} | "
    end
    desc << location.description
    desc[0..154]
  end
end
