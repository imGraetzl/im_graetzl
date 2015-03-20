class RegistrationsController < Devise::RegistrationsController

  def address
    session[:graetzls] = nil
    # if params[:street]
    #   street = params[:street]
    #   number = params[:number] || ''
    #   query = "http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{street}&crs=EPSG:4326"
    #   uri = URI.parse(URI.encode(query))
    #   response = HTTParty.get(uri)
    #   @address = response['features'][0]
    #   @coords = @address['geometry']['coordinates']
    #   @graetzls = ['grätzl_1', 'grätzl_2', 'grätzl_3']
    # end
    #build_resource({})
    session[:graetzls] = ['grätzl_1', 'grätzl_2', 'grätzl_3']
    @graetzls = session[:graetzls]
    respond_to do |format|
      format.html { redirect_to new_user_registration_path }
      format.js # otherwise just execute some js
    end
  end

  def new
    @graetzls = session[:graetzls]
    session[:graetzls] = nil
    super
  end

  # def create_user(registration_params)
  #   build_resource(registration_params)
  #   session[:registration_params] = session[:registration_step] = nil

  #   resource.save
  #   yield resource if block_given?
  #   if resource.persisted?
  #     if resource.active_for_authentication?
  #       set_flash_message :notice, :signed_up if is_flashing_format?
  #       sign_up(resource_name, resource)
  #       respond_with resource, location: after_sign_up_path_for(resource)
  #     else
  #       set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
  #       expire_data_after_sign_in!
  #       respond_with resource, location: after_inactive_sign_up_path_for(resource)
  #     end
  #   else
  #     clean_up_passwords resource
  #     set_minimum_password_length
  #     respond_with resource
  #   end
  # end

end
