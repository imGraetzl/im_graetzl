module MapsHelper
  def google_map_url(address)
    "https://maps.google.com?"\
    "q=#{address.street_name}+#{address.street_number}"
  end

  def static_map_url(coords, options={})
    options = static_map_defaults.merge(options)
    "https://maps.google.com/maps/api/staticmap?"\
    "key=#{options[:key]}&"\
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
      marker: 'small',
      key: ENV['GOOGLE_API_KEY']
    }
  end
end
