class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /users/registrierung
  def new
    if params[:feature].blank?
      render "address_form" and return
    end

    build_resource(origin: params[:origin])
    address_resolver = AddressResolver.from_json(params[:feature])
    self.resource.graetzl = address_resolver.graetzl
    self.resource.build_address(address_resolver.address_fields)
    respond_with self.resource
  end

  def create
    session[:confirmation_redirect] = params[:redirect] if params[:redirect].present?
    super
  end

  protected

  def after_inactive_sign_up_path_for(_resource)
    params[:redirect] || root_url
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(
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
          :coordinates])
    end
  end

end
