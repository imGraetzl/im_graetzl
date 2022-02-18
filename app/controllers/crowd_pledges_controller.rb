class CrowdPledgesController < ApplicationController
  before_action :authenticate_user!, except: [:new]

  def new
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    if user_signed_in?
      @crowd_pledge.assign_attributes(current_user_address_params)
    else
      render 'login'
    end
  end

  def create
    @crowd_pledge = current_user.crowd_pledges.build(crowd_pledge_params)
    @crowd_pledge.save!
    redirect_to [:choose_payment, @crowd_pledge]
  end

  def choose_payment
    @crowd_pledge = current_user.crowd_pledges.find(params[:id])
  end

  def summary
    @crowd_pledge = current_user.crowd_pledges.find(params[:id])
  end

  def initiate_card_payment
    @tool_rental = current_user.tool_rentals.incomplete.find(params[:id])
    result = ToolRentalService.new.initiate_card_payment(@tool_rental, card_params)
    render json: result, status: result[:error].present? ? :bad_request : :ok
  end

  def initiate_eps_payment
    @tool_rental = current_user.tool_rentals.incomplete.find(params[:id])
    result = ToolRentalService.new.initiate_eps_payment(@tool_rental)
    render json: result, status: result[:error].present? ? :bad_request : :ok
  end

  def complete_eps_payment
    @tool_rental = current_user.tool_rentals.find(params[:id])
    if params[:redirect_status] == 'succeeded'
      redirect_to [:summary, @tool_rental]
    else
      flash[:error] = "EPS Überweisung gescheitert."
      redirect_to [:choose_payment, @tool_rental]
    end
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
      :crowd_campaign_id, :crowd_reward_id, :amount,
      :contact_name, :address_street, :address_zip, :address_city, :anwser
    )
  end

  def card_params
    params.permit(:payment_method_id, :payment_intent_id)
  end

  def eps_params
    params.permit(:payment_intent)
  end

end
