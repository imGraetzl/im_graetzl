class RegistrationsController < Devise::RegistrationsController

  def new
    super
    session[:registration_params] ||= {}
    puts "allasdfhalsidfhaksdfhlkahjskdfhlkashlkdfhlsaf"
    puts resource # = @user...
  end

  def create
    session[:registration_params].deep_merge! sign_up_params if sign_up_params
    @user = build_resource(session[:registration_params])

    @user.registration_step = session[:registration_step]

    if params[:back_button]
      @user.previous_registration_step
    elsif @user.last_step?
      # todo: validations....
      session[:registration_params] = session[:registration_step] = nil
      return super
    else
      @user.next_registration_step
    end
    
    session[:registration_step] = @user.registration_step
    render 'new'
  end

  # prepend_before_filter :require_no_authentication, :only => [ :cancel ]
  # prepend_before_filter :authenticate_scope!, :only => [ :new, :create, :edit, :update, :destroy ]

  # def new
  #   if user_signed_in? && current_user.admin?
  #     super
  #   else
  #     set_flash_message :alert, :not_authorized
  #     redirect_to users_path
  #   end
  # end

  # protected

  # def sign_up(resource_name, resource)
  # end

  # def after_sign_up_path_for(resource)
  #   if resource.is_a?(User)
  #     users_path
  #   end
  # end

  # def after_update_path_for(resource)
  #   if resource.is_a?(User)
  #     user_path(current_user)
  #   end
  # end

end
