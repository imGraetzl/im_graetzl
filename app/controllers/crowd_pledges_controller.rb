class CrowdPledgesController < ApplicationController
  before_action :authenticate_user!, except: [:new]

  def new
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    render 'login' and return if !user_signed_in?
  end

  def address
    if params[:id].present?
      @crowd_pledge = current_user.crowd_pledges.find(params[:id])
      @crowd_pledge.update(crowd_pledge_params)
    else
      @crowd_pledge = CrowdPledge.new(current_user_address_params)
      @crowd_pledge.assign_attributes(crowd_pledge_params)
    end
  end

  def create
    @crowd_pledge = current_user.crowd_pledges.build(crowd_pledge_params)
    @crowd_pledge.save!
    redirect_to [:address, @crowd_pledge]
  end

  def choose_payment
    @crowd_pledge = current_user.crowd_pledges.find(params[:id])
  end

  def summary
    @crowd_pledge = current_user.crowd_pledges.find(params[:id])
  end

  private

  def initial_pledge_params
    params.permit(:crowd_campaign_id, :crowd_reward_id)
  end

  def current_user_address_params
    {
      contact_name: current_user.full_name,
      address_street: current_user.address_street,
      address_zip: current_user.address_zip,
      address_city: current_user.address_city,
    }
  end

  def crowd_pledge_params
    params.require(:crowd_pledge).permit(
      :crowd_campaign_id, :crowd_reward_id,
      :contact_name, :address_street, :address_zip, :address_city, :anwser
    )
  end

end
