class Users::RegistrationsController < Devise::RegistrationsController
  # GET /users/registrierung
  def new

    if current_region.nil?
      render 'select_region', layout: 'platform'
    else
      if params[:feature].blank?
        render "address_form" and return
      end

      build_resource(origin: params[:origin])
      address_resolver = AddressResolver.from_json(params[:feature])
      self.resource.graetzl = address_resolver.graetzl
      self.resource.build_address(address_resolver.address_fields)
      respond_with self.resource
    end

  end

  def create
    session[:confirmation_redirect] = params[:redirect] if params[:redirect].present?

    build_resource(sign_up_params)
    resource.region_id = current_region.id
    resource.save

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        resource.send_confirmation_instructions
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_inactive_sign_up_path_for(_resource)
    params[:redirect] || root_url
  end

  def sign_up_params
    params.require(:user).permit(
      :username,
      :first_name, :last_name,
      :email,
      :password,
      :business,
      :terms_and_conditions,
      :newsletter,
      :origin,
      :avatar, :remove_avatar,
      :graetzl_id,
      :location_category_id,
      business_interest_ids: [],
      address_attributes: [
        :street_name,
        :street_number,
        :zip,
        :city,
        :coordinates]
      )
  end

end
