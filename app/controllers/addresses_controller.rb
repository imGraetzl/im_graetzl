class AddressesController < ApplicationController

  def registration    
  end

  def search
    @search_input = params[:address]
    address = Address.new_from_json_string(params[:feature] || '')
    session[:address] = address.attributes
    @graetzls = address.match_graetzls
    if @graetzls.size == 1
      session[:graetzl] = @graetzls.first.id
      redirect_to new_user_registration_path
    end
  end

  def match
    graetzl = Graetzl.find(params[:graetzl])
    session[:graetzl] = graetzl.id
    redirect_to new_user_registration_path
  end

  def update_graetzls
    district = District.find(params[:district_id])
    @graetzls = district.graetzls
  end
end