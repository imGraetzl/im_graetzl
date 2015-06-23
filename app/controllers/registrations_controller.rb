class RegistrationsController < Devise::RegistrationsController
  
  # modify devise to allow additional user attributes
  before_action :configure_permitted_parameters

  def new
    if session[:graetzl].present?
      build_resource({})
      self.resource.build_address(session[:address] ||= {})
      self.resource.build_graetzl(Graetzl.find(session[:graetzl]).attributes)
      respond_with self.resource
    else
      redirect_to user_registration_address_path
    end
  end

  def create
    puts params
    clear_session_data
    super    
  end

  def address    
  end

  def set_address
    @search_input = params[:address]
    address = Address.new(Address.attributes_from_feature(params[:feature] || ''))
    session[:address] = address.attributes
    @graetzls = address.graetzls
    if @graetzls.size == 1
      session[:graetzl] = @graetzls.first.id
      redirect_to new_user_registration_path
    else
      render :graetzl
    end
  end

  def set_graetzl
    graetzl = Graetzl.find(params[:graetzl])
    session[:graetzl] = graetzl.id
    redirect_to new_user_registration_path
  end

  def graetzl
    @graetzls = []
    if request.xhr?  
      district = District.find(params[:district_id])
      @graetzls = district.graetzls
    end
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
          :avatar, :remove_avatar,
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

    def clear_session_data
      session.delete(:address)
      session.delete(:graetzl)
    end
end