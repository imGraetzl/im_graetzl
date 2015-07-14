class LocationsController < ApplicationController
  before_filter :set_graetzl

  # GET /new/address
  def new_address
  end

  # POST /new/address
  def set_new_address
    puts address_params    
    #@search_input = address_params[:address]
    address = Address.new(Address.attributes_from_feature(address_params[:feature] || ''))
    session[:address] = address.attributes
    @graetzl = address.graetzl || @graetzl
    @locations = address.locations

    if @locations.empty?
      #build_location(address)
      redirect_to new_graetzl_location_path(@graetzl)
      #render :new
    else
      render :new_adopt
    end
  end

  def new_adopt    
  end

  def new
    puts params
    @location = @graetzl.locations.build(address_attributes: session[:address])
    @location.build_contact

    #@graetzl.locations.build(address: @address)
    
  end

  private

    def set_graetzl
      @graetzl = Graetzl.find(params[:graetzl_id])
    end

    # strong params for address
    def address_params
      params.permit(:address, :feature)
    end
end
