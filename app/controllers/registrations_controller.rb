class RegistrationsController < Devise::RegistrationsController

  def address
    
  end

  def new
    super
    session[:registration_params] ||= {}
    resource.registration_step = session[:registration_step]
  end

  def create
    if session[:registration_step] == 'address'
      search_address(params[:search])
    end

    session[:registration_params].deep_merge! sign_up_params if sign_up_params
    @user = build_resource(session[:registration_params])

    @user.registration_step = session[:registration_step]

    if params[:back_button]
      @user.previous_registration_step
    elsif @user.last_step?
      return create_user(session[:registration_params]) if @user.valid?
    else
      @user.next_registration_step
    end
    
    session[:registration_step] = @user.registration_step
    render 'new'
  end

  def create_user(registration_params)
    build_resource(registration_params)
    session[:registration_params] = session[:registration_step] = nil

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end


  # tempchaos

  def search_address(address)
    uri = URI.parse("http://data.wien.gv.at/daten/OGDAddressService.svc/GetAddressInfo?Address=#{address}&crs=EPSG:4326")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    puts "Search for: #{address}"

    if response.code == "200"
      result = JSON.parse(response.body)
      
      result.each do |doc|
        #puts doc["id"] #reference properties like this
        puts doc # this is the result in object form    
        puts ""
        puts ""
      end
    else
      puts "ERROR!!!"
    end
  end

end
