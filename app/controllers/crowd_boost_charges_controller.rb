class CrowdBoostChargesController < ApplicationController
  before_action :load_crowd_boost, only: [:new, :choose_region, :create, :login, :calculate_price]

  def new
    @crowd_boost_charge = @crowd_boost.crowd_boost_charges.build(initial_charge_params)
    @crowd_boost_charge.assign_attributes(current_user_params) if current_user

    unless @crowd_boost.chargeable?
      flash[:notice] = "Sorry, aktuell ist eine Einzahlung in diesen Topf nicht möglich."
      redirect_to @crowd_boost
    end

    unless current_region
      render :choose_region, layout: 'platform'
    end
  end

  def create
    @crowd_boost_charge = @crowd_boost.crowd_boost_charges.build(crowd_boost_charge_params)
    @crowd_boost_charge.region_id = current_region.id
    @crowd_boost_charge.user_id = current_user.id if current_user
    @crowd_boost_charge.payment_status = "incomplete"

    if @crowd_boost_charge.save
      redirect_to [:choose_payment, @crowd_boost_charge]
    else
      render :new
    end
  end

  def choose_region
    @crowd_boost_charge = @crowd_boost.crowd_boost_charges.build(initial_charge_params)
  end

  def login
    @crowd_boost_charge = @crowd_boost.crowd_boost_charges.build(initial_charge_params)
  end

  def calculate_price
    head :ok and return if browser.bot? && !request.format.js?
    @crowd_boost_charge = @crowd_boost.crowd_boost_charges.build(initial_charge_params)
  end

  def choose_payment
    @crowd_boost_charge = CrowdBoostCharge.find(params[:id])
    @crowd_boost = @crowd_boost_charge.crowd_boost
    redirect_to [:summary, @crowd_boost_charge] and return if !(@crowd_boost_charge.incomplete? || @crowd_boost_charge.failed?)
    @payment_intent = CrowdBoostService.new.create_payment_intent(@crowd_boost_charge)
  end

  def payment_authorized
    @crowd_boost_charge = CrowdBoostCharge.find(params[:id])
    @crowd_boost = @crowd_boost_charge.crowd_boost
    redirect_to [:choose_payment, @crowd_boost_charge] if params[:payment_intent].blank?

    success, error = CrowdBoostService.new.payment_authorized(@crowd_boost_charge, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."
      redirect_to [:summary, @crowd_boost_charge]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @crowd_boost_charge]
    end
  end

  def summary
    @crowd_boost_charge = CrowdBoostCharge.find(params[:id])
    @crowd_boost = @crowd_boost_charge.crowd_boost
  end

  def details
    @crowd_boost_charge = CrowdBoostCharge.find(params[:id])
    @crowd_boost = @crowd_boost_charge.crowd_boost
    redirect_to @crowd_boost if @crowd_boost_charge.incomplete?
  end

  private

  def load_crowd_boost
    redirect_to root_url and return if params[:crowd_boost_id].blank?
    @crowd_boost = CrowdBoost.find(params[:crowd_boost_id])
  end

  def initial_charge_params
    params.permit(:amount)
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

  def crowd_boost_charge_params
    params.require(:crowd_boost_charge).permit(
      :amount, :anonym, :terms, :guest_newsletter,
      :email, :contact_name, :address_street, :address_zip, :address_city
    )
  end

end
