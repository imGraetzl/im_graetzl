class AddressesController < ApplicationController

  def fetch
    @graetzls = []
    unless params[:address].empty?
      address = params[:address]
      query = "http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{address}&crs=EPSG:4326"
      uri = URI.parse(URI.encode(query))
      response = HTTParty.get(uri)

      if response
        feature = response['features'][0]
        point = RGeo::GeoJSON.decode(feature['geometry'], :json_parser => :json)
        @address = Address.new(coordinates: point,
          street_name: feature['properties']['StreetName'],
          street_number: feature['properties']['StreetNumber'],
          zip: feature['properties']['PostalCode'],
          city: feature['properties']['Municipality'])
        
        @graetzls = @address.match_graetzl
      end
    end

    respond_to do |format|
      #format.html { redirect_to root_url }
      format.js
    end    
  end
end
