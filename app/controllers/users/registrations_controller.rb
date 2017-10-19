class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /users/registrierung
  def new
    if session[:address].blank?
      render "address_form" and return
    end

    build_resource({})
    self.resource.build_address(session.delete(:address) || {})
    self.resource.graetzl = Graetzl.find(params[:graetzl_id])
    respond_with self.resource
  end

  def set_address
    @address = Address.from_feature(params[:feature])
    session[:address] = @address.attributes

    if @address.graetzls.size == 1
      redirect_to new_registration_url(graetzl_id: @address.graetzls.first.id)
    else
      redirect_to graetzls_registration_url(address: params[:address], feature: params[:feature])
    end
  end

  def graetzls
    @search_input = params[:address]
    address = Address.from_feature(params[:feature])
    @graetzls = address.graetzls
  end

  def set_graetzl
    redirect_to new_registration_url(graetzl_id: params[:graetzl_id])
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(
        :username,
        :first_name, :last_name,
        :email,
        :password,
        :terms_and_conditions,
        :newsletter,
        :role,
        :avatar, :remove_avatar,
        :graetzl_id,
        address_attributes: [
          :street_name,
          :street_number,
          :zip,
          :city,
          :coordinates])
    end
  end

end
