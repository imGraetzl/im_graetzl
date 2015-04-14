class AddressesController < ApplicationController

  def registration    
  end

  def search
    if params[:address].blank?
      flash[:error] = 'Please enter address.'
      render :registration
    else
      address = get_address_from_api(params[:address])
      graetzl = address.match_graetzls.first
      session[:address] = address.attributes
      #session[:address] = nil
      session[:graetzl] = graetzl.attributes
      redirect_to new_user_registration_path
    end
    #puts "search address search address search address search address"
    #redirect_to new_user_registration_path    
  end

  after_filter { flash.discard if request.xhr? }

  def fetch_graetzl
    if params[:address].blank?
      flash[:error] = 'Please enter address.'
      render :no_address
    else
      @address = get_address_from_api(params[:address])
      @graetzls = @address.match_graetzls
    end
  end

  private

  def get_address_from_api(address_string)
    response = query_address_service(address_string)
    if !response.blank? && response.body.present?
      #puts "Address: #{response['features'][0]}"
      return Address.new_from_geojson(response['features'][0])
    end
    Address.new()
  end

  def query_address_service(address_string)
    query = "http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{address_string}&crs=EPSG:4326"
    uri = URI.parse(URI.encode(query))
    begin
      HTTParty.get(uri)
    rescue
      nil
    end
  end
end