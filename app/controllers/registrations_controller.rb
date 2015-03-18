class RegistrationsController < Devise::RegistrationsController

  def new
    super
    session[:registration_params] ||= {}
    resource.registration_step = session[:registration_step]
  end

  def create
    session[:registration_params].deep_merge! sign_up_params if sign_up_params
    @user = build_resource(session[:registration_params])

    @user.registration_step = session[:registration_step]

    if params[:back_button]
      @user.previous_registration_step
    elsif @user.last_step?
      return create_user(session[:registration_params]) if @user.valid?
      # if @user.valid?
      #   # todo: validations....
      #   session[:registration_params] = session[:registration_step] = nil
      #   return super
      # end
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
