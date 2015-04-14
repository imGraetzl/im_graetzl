class AddressesController < ApplicationController

  def registration    
  end

  def search
    if params[:address].blank?
      flash.now[:error] = 'Bitte gib eine Addresse an.'
      render :registration
    else
      address = get_address_from_api(params[:address])
      session[:address] = address.attributes
      @graetzls = address.match_graetzls
      if @graetzls.size == 1
        session[:graetzl] = @graetzls.first.id
        redirect_to new_user_registration_path
      end
    end
  end

  def match
    if params[:graetzl].blank?
      flash.now[:error] = 'Bitte wähle ein Grätzl.'
      render :registration
    else
      graetzl = Graetzl.find(params[:graetzl])
      session[:graetzl] = graetzl.id
      redirect_to new_user_registration_path
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