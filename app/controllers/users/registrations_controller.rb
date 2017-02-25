class Users::RegistrationsController < Devise::RegistrationsController
  include AddressBeforeNew
  before_action :configure_sign_up_params, only: [:create]

  # GET /users/registrierung
  def new
    render :graetzl and return if multiple_graetzl?

    # otherwise
    @graetzl ||= Graetzl.find(session[:graetzl])
    build_resource({})
    self.resource.build_address(session[:address] ||= {})
    self.resource.graetzl = @graetzl
    empty_session
    respond_with self.resource
  end

  def graetzl
    # TODO: improve that...
    if request.post?
      graetzl = Graetzl.find(params[:graetzl_id])

      # build resources
      build_resource({})
      self.resource.build_address(session[:address] ||= {})
      self.resource.graetzl = graetzl
      empty_session
      render :new
    end
  end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

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

  def multiple_graetzl?
    if request.post?
      @graetzls = @address.graetzls
      return @graetzls.size != 1
    end
  end
end
