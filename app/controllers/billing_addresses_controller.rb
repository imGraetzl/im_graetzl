class BillingAddressesController < ApplicationController
  before_action :authenticate_user!

  def show
    set_zuckerl_and_location
    @billing_address = @location.billing_address || @location.build_billing_address
  end

  def create
    set_zuckerl_and_location
    @billing_address = @location.build_billing_address billing_address_params
    if @billing_address.save
      redirect_to zuckerl_billing_address_path(@zuckerl), notice: 'Deine Rechnungsadresse wurde hinterlegt.'
    else
      render :show
    end
  end

  def update
    set_zuckerl_and_location
    @billing_address = @location.billing_address
    @billing_address.attributes = billing_address_params
    if @billing_address.save
      redirect_to zuckerl_billing_address_path(@zuckerl), notice: 'Deine Rechnungsadresse wurde aktualisiert.'
    else
      render :show
    end
  end

  private

  def set_zuckerl_and_location
    @zuckerl = Zuckerl.find params[:zuckerl_id]
    @location = @zuckerl.location
  end

  def billing_address_params
    params.require(:billing_address).permit(
      :full_name,
      :company,
      :street,
      :full_city)
  end
end
