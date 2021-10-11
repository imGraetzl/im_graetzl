class GeoResolver

  def find_region(lng, lat)
    coordinates = [lng.to_f, lat.to_f]
    Region.all.find{|r| Graetzl.find_by_coords(r, coordinates).present? }
  end

end
