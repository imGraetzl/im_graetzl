class RegistrationsController < Devise::RegistrationsController
  
  # modify devise to allow additional user attributes
  before_action :configure_permitted_parameters

  def new
    build_resource({})
    self.resource.build_address
    self.resource.build_graetzl
    respond_with self.resource
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(
        :username,
        :gender,
        :birthday,
        :first_name, :last_name,
        :email,
        :password, :password_confirmation,
        :terms_and_conditions,
        :newsletter,
        :avatar,
        :avatar_cache,
        address_attributes: [
          :street_name,
          :street_number,
          :zip,
          :city,
          :coordinates],
        graetzl_attributes: [
          :name])
    end
    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:login, :username, :email, :password, :remember_me)
    end
  end
end