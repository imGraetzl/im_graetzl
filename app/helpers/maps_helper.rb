module MapsHelper
  def map_link(coords)
    "http://www.openstreetmap.org/?mlat=#{coords.y}&mlon=#{coords.x}&zoom=18"
  end

  def google_map_url(address)
    "http://maps.google.com?"\
    "q=#{address.street_name}+#{address.street_number}"
  end

  def static_map_url(coords, options={})
    options = static_map_defaults.merge(options)
    "http://maps.google.com/maps/api/staticmap?"\
    "center=#{coords.y},#{coords.x}&"\
    "zoom=#{options[:zoom]}&"\
    "size=#{options[:size].join('x')}&"\
    "scale=#{options[:scale]}&"\
    "markers=size:#{options[:marker]}|#{coords.y},#{coords.x}"
  end

  private
  
  def static_map_defaults
    {
      zoom: 15,
      size: [79,100],
      scale: 2,
      marker: 'small'
    }
  end
end
