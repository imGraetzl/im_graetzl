class CrowdPledgesController < ApplicationController
  #before_action :authenticate_user!, except: [:choose_amount, :choose_payment, :new]

  def new
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    redirect_to @crowd_pledge.crowd_campaign and return if !@crowd_pledge.crowd_campaign.funding?

    if user_signed_in?
      @crowd_pledge.assign_attributes(current_user_params)
    end
    @crowd_pledge.calculate_price
  end

  def create
    @crowd_pledge = CrowdPledge.new(crowd_pledge_params)
    redirect_to @crowd_pledge.crowd_campaign and return if !@crowd_pledge.crowd_campaign.funding?

    @crowd_pledge.user_id = current_user.id if current_user
    @crowd_pledge.calculate_price

    if @crowd_pledge.save
      redirect_to [:choose_payment, @crowd_pledge]
    else
      render :new
    end
  end

  def calculate_price
    head :ok and return if browser.bot? && !request.format.js?
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def choose_amount
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    redirect_to @crowd_pledge.crowd_campaign and return if !@crowd_pledge.crowd_campaign.funding?

    @crowd_pledge.calculate_price
  end

  def login
    @crowd_pledge = CrowdPledge.new(initial_pledge_params)
    redirect_to @crowd_pledge.crowd_campaign and return if !@crowd_pledge.crowd_campaign.funding?

    @crowd_pledge.calculate_price
  end

  def choose_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to @crowd_pledge.crowd_campaign and return if !@crowd_pledge.crowd_campaign.funding?

    @crowd_pledge.calculate_price
    @setup_intent = CrowdPledgeService.new.create_setup_intent(@crowd_pledge)
  end

  def payment_authorized
    @crowd_pledge = CrowdPledge.find(params[:id])
    CrowdPledgeService.new.card_payment_authorized(@crowd_pledge, params[:payment_method_id])
    ActionProcessor.track(@crowd_pledge, :create)
    # CrowdMailer.new_pledge(@crowd_pledge)
    redirect_to [:summary, @crowd_pledge]
  end

  def summary
    @crowd_pledge = CrowdPledge.find(params[:id])
  end

  private

  def initial_pledge_params
    params.permit(:crowd_campaign_id, :crowd_reward_id, :donation_amount, :answer)
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
      :crowd_campaign_id, :crowd_reward_id, :donation_amount, :anonym,
      :email, :contact_name, :address_street, :address_zip, :address_city, :answer
    )
  end

  def card_params
    params.permit(:payment_method_id)
  end

end
