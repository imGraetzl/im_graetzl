module MapsHelper

  def area_map(areas, js)
    javascript_tag("window.addEventListener('load', function() {if ($('#area-map').is(':visible')) {#{js}}});") +
    content_tag(:div, nil, id: "area-map", data: { areas: MapData.new.encode(areas) }) +
    content_tag(:div, nil, class: "activeArea")
  end

  def favorite_graetzl_map(areas, favorites, home, js)
    javascript_tag("window.addEventListener('load', function() {if ($('#area-map').is(':visible')) {#{js}}});") +
    content_tag(:div, nil, id: "area-map", data: { areas: MapData.new.encode_favorite_graetzls(areas, favorites, home) }) +
    content_tag(:div, nil, class: "activeArea")
  end

  def address_map(object)
    coordinates = object.address_coordinates
    content_tag(:div, nil, id: 'leafletMap', data: {x: coordinates.x, y: coordinates.y}) do
      content_tag(:div, class: 'map-marker -hidden') do
        link_to(icon_tag("pin"), "https://maps.google.com?q=#{coordinates.y},#{coordinates.x}", target: '_blank')
      end
    end
  end

  def region_map(region, js)
    javascript_tag("window.addEventListener('load', function() {if ($('#area-map').is(':visible')) {#{js}}});") +
    content_tag(:div, nil, id: "area-map", data: { areas: region.area } ) +
    content_tag(:div, nil, class: "activeArea")
  end

end
