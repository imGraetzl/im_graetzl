class AddressesController < ApplicationController
  after_filter { flash.discard if request.xhr? }

  def fetch_graetzl
    puts params
    if params[:address].present?
      @address = get_address_from_api(params[:address])
      @graetzls = @address.match_graetzls
    else
      flash[:error] = 'Please enter address.'
      render 'no_address'
    end
  end

  private

  def get_address_from_api(address_string)
    response = query_address_service(address_string)
    if response
      Address.new_from_geojson(response['features'][0])
    else
      Address.new()
    end 
  end

  def query_address_service(address_string)
    query = "http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{address_string}&crs=EPSG:4326"
    uri = URI.parse(URI.encode(query))
    begin
      HTTParty.get(uri)
    rescue
      # no api response, render whole grätzl list
      nil
    end
  end
end