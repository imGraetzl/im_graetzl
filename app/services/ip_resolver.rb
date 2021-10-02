class IpResolver

  def find_region(ip)
    response = Http.get("http://ipwhois.app/json/#{ip}").parse(:json)

    if response["longitude"] && response["latitude"]
      coordinates = [response["longitude"], response["latitude"]]
      Region.all.find{|r| Graetzl.find_by_coords(r, coordinates).present? }
    end
  end

end