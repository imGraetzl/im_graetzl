module RoomsHelper

  def filter_room_types
    [
      ['Alle Raumteiler', ''],
      ['Räume', 'offer'],
      ['Raumsuchende', 'demand'],
    ]
  end

  def room_rental_default_hours_from
    (6..23).map{ |h| ["#{h}:00", h] }
  end

  def room_rental_default_hours_to
    (7..24).map{ |h| ["#{h}:00", h] }
  end

  def room_discount_values
    [5, 10, 15, 20, 25, 30, 40, 50].map do |value|
      ["#{value} %", value]
    end
  end

  def minimum_rental_hour_values
    [1, 2, 3, 4, 5, 6, 7, 8].map do |value|
      ["#{value} h", value]
    end
  end

  def room_rental_params
    params.permit(
      :room_offer_id, :rent_from, :rent_to, :renter_company, :renter_name, :renter_address,
      :renter_zip, :renter_city,
    )
  end

end
