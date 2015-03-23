class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, only: [:address]

  def address
    session[:graetzls] = nil
    @graetzls = []
    if params[:address]
      address = params[:address]
      query = "http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{address}&crs=EPSG:4326"
      uri = URI.parse(URI.encode(query))
      response = HTTParty.get(uri)

      if response
        @address = response['features'][0]
        @graetzls << @address['properties']['MunicipalitySubdivision']
      end
    end
    respond_with do |format|
      if request.xhr?
        format.js
      else
        session[:graetzls] = @graetzls
        format.html { redirect_to new_user_registration_path }
      end
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
