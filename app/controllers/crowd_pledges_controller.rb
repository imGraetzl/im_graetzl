class CrowdPledgesController < ApplicationController
  #before_action :authenticate_user!, except: [:choose_amount, :choose_payment, :new]

  def new
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    @crowd_reward = @crowd_pledge.crowd_reward
    if user_signed_in?
      @crowd_pledge.assign_attributes(current_user_params)
    end
  end

  def create
    @crowd_campaign = CrowdCampaign.find(params[:crowd_pledge][:crowd_campaign_id])
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(crowd_pledge_params)
    @crowd_pledge.user_id = current_user.id if current_user
    @crowd_reward = @crowd_pledge.crowd_reward

    if @crowd_pledge.save
      redirect_to [:choose_payment, @crowd_pledge]
      ActionProcessor.track(@crowd_campaign, :crowd_pledge, @crowd_pledge) # Move to after authorized Payment 
    else
      render :new
    end
  end

  def calculate_price
    head :ok and return if browser.bot? && !request.format.js?
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    @crowd_reward = @crowd_pledge.crowd_reward
    #head :bad_request and return if @crowd_pledge.amount.blank?
  end

  def choose_amount
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    @crowd_reward = @crowd_pledge.crowd_reward
  end

  def login
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    @crowd_reward = @crowd_pledge.crowd_reward
  end

  def choose_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    @crowd_reward = @crowd_pledge.crowd_reward
  end

  def summary
    @crowd_pledge = CrowdPledge.find(params[:id])
    @crowd_reward = @crowd_pledge.crowd_reward
  end

  def initiate_card_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    result = CrowdPledgeService.new.initiate_card_payment(@crowd_pledge, card_params)
    render json: result, status: result[:error].present? ? :bad_request : :ok
  end

  def initiate_eps_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    result = CrowdPledgeService.new.initiate_eps_payment(@crowd_pledge)
    render json: result, status: result[:error].present? ? :bad_request : :ok
  end

  def complete_eps_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    if params[:redirect_status] == 'succeeded'
      redirect_to [:summary, @crowd_pledge]
    else
      flash[:error] = "EPS Überweisung gescheitert."
      redirect_to [:choose_payment, @crowd_pledge]
    end
  end

  private

  def initial_pledge_params
    params.permit(:crowd_campaign_id, :crowd_reward_id, :amount, :anwser)
  end

  def current_user_params
    {
      email: current_user.email,
      contact_name: current_user.full_name,
      address_street: current_user.address_street,
      address_zip: current_user.address_zip,
      address_city: current_user.address_city,
    }
  end

  def crowd_pledge_params
    params.require(:crowd_pledge).permit(
      :crowd_campaign_id, :crowd_reward_id, :amount, :anonym,
      :email, :contact_name, :address_street, :address_zip, :address_city, :anwser
    )
  end

  def card_params
    params.permit(:payment_method_id, :payment_intent_id)
  end

  def eps_params
    params.permit(:payment_intent)
  end

end
