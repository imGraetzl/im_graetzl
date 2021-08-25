class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  def after_confirmation_path_for(_resource_name, resource)
    sign_in(resource)
    if resource.business?
      set_flash_message! :notice, :confirmed_business_and_signed_in, :link => ActionController::Base.helpers.link_to('kostenloses virtuelles Schaufenster', locations_user_path), :first_name => resource.first_name
    end
    session.delete(:confirmation_redirect) || root_url
  end
end
