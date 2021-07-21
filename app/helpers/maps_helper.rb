module MapsHelper

  def area_map(areas)
    content_tag(:div, nil, id: "area-map", data: { areas: MapData.new.encode(areas) }) +
    content_tag(:div, nil, class: "activeArea")
  end

end
