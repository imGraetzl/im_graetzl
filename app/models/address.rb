module Address

  def using_address?
    address_street.present?
  end

  def clear_address
    assign_attributes(
      address_street: nil,
      address_zip: nil,
      address_city: nil,
      address_coordinates: nil,
    )
  end

  def full_address
    "#{address_street}, #{address_zip} #{address_city}" if using_address?
  end

  def address_hash
    {
      address_street: address_street,
      address_zip: address_zip,
      address_city: address_city,
      address_coords: address_coords,
      address_description: address_description,
      graetzl_id: graetzl_id,
    }
  end

  def address_coords
    "#{address_coordinates.x},#{address_coordinates.y}" if address_coordinates.present?
  end

  def address_coords=(value)
    if value.present?
      coordinates = value.split(",").map(&:to_f)
      self.address_coordinates = RGeo::Cartesian.factory(srid: 0).point(*coordinates)
    else
      self.address_coordinates = nil
    end
  end

end
