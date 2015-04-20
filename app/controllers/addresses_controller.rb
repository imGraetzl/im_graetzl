class AddressesController < ApplicationController

  def registration    
  end

  def search
    if params[:address].blank?
      flash.now[:error] = 'Bitte gib eine Addresse an.'
      render :registration
    else
      address = Address.get_address_from_api(params[:address])
      session[:address] = address.attributes
      @graetzls = address.match_graetzls
      if @graetzls.size == 1
        session[:graetzl] = @graetzls.first.id
        redirect_to new_user_registration_path
      end
    end
  end

  def match
    if params[:graetzl].blank?
      flash.now[:error] = 'Bitte wähle ein Grätzl.'
      render :registration
    else
      graetzl = Graetzl.find(params[:graetzl])
      session[:graetzl] = graetzl.id
      redirect_to new_user_registration_path
    end    
  end
end