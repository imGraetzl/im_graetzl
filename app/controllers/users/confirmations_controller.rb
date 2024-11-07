class Users::ConfirmationsController < Devise::ConfirmationsController

layout :set_layout

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
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    
    if resource.errors.empty?
      # Merge Guest User with current user if guest exists
      resource.merge_with_guest_user
      set_flash_message!(:notice, :confirmed)
      sign_in(resource)
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  def after_confirmation_path_for(_resource_name, resource)
    sign_in(resource)
    if resource.business?
      set_flash_message! :notice, :confirmed_business_and_signed_in, :link => ActionController::Base.helpers.link_to('kostenloses Schaufenster', locations_user_path), :first_name => resource.first_name
    end
    session.delete(:confirmation_redirect) || root_url
  end

  private

  def set_layout
    if current_region.nil?
      'platform'
    else
      'application'
    end
  end

end
