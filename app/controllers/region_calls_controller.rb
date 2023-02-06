class RegionCallsController < ApplicationController
  layout 'platform'

  def call
    @region_call = RegionCall.new
  end

  def create
    @region_call = RegionCall.new(region_call_params)
    if @region_call.save
      redirect_to params[:redirect_path]
      flash[:notice] = "Vielen Dank für Ihre Anmeldung! Wir melden uns in Kürze!"
      AdminMailer.new_region_call(@region_call).deliver_later
    else
      render 'call'
    end
  end

  private

  def region_call_params
    params.require(:region_call).permit(
      :region_type,
      :region_id,
      :name,
      :personal_position,
      :gemeinden,
      :email,
      :phone,
      :message
    )
  end

end
