class AddressesController < ApplicationController

  def registration    
  end

  def search
    puts params[:feature]
    if params[:address].blank?
      flash.now[:error] = 'Bitte gib eine Addresse an.'
      render :registration
    else
      @search_input = params[:address]
      #address = Address.get_address_from_api(@search_input)
      address = Address.parse_feature(params[:feature])
      puts "address point: #{address.coordinates}"
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
      @search_input = params[:address]
      @graetzls = Address.new(session[:address]).match_graetzls
      render :search
    else
      graetzl = Graetzl.find(params[:graetzl])
      session[:graetzl] = graetzl.id
      redirect_to new_user_registration_path
    end    
  end
end