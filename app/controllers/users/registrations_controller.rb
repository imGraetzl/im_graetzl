class Users::RegistrationsController < Devise::RegistrationsController
  # GET /users/registrierung
  def new
    if current_region.nil?
      render 'select_region', layout: 'platform' and return
    elsif params.dig(:user, :address_street).blank?
      render "select_address" and return
    end

    build_resource(sign_up_params)
    respond_with self.resource
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
        # Nur Bestätigungs-E-Mail senden, wenn sie noch nicht gesendet wurde
        resource.send_confirmation_instructions if resource.confirmation_sent_at.nil?
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
      :username, :first_name, :last_name, :email, :password,
      :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
      :avatar, :remove_avatar,
      :origin, :terms_and_conditions, :newsletter, :location_category_id, :business, business_interest_ids: [],
    )
  end

end
