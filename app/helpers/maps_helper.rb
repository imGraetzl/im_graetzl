module MapsHelper

  def area_map(areas)
    content_tag(:div, nil, id: "area-map", data: { areas: MapData.new.encode(areas) }) +
    content_tag(:div, nil, class: "activeArea")
  end

  def address_map(object)
    coordinates = object.address_coordinates
    content_tag(:div, nil, id: 'leafletMap', data: {x: coordinates.x, y: coordinates.y}) do
      content_tag(:div, class: 'map-marker -hidden') do
        link_to(icon_tag("pin"), "https://maps.google.com?q=#{object.address_street}+#{object.address_zip}", target: '_blank')
      end
    end
  end

end
