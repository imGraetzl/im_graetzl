class ToolRentalsController < ApplicationController
  before_action :authenticate_user!, except: [:new, :change_payment, :payment_changed, :summary]

  def new
    @tool_rental = ToolRental.new(initial_rental_params)
    @tool_rental.calculate_price
    if user_signed_in?
      @tool_rental.assign_attributes(current_user_address_params)
    else
      render 'login'
    end
  end

  def create
    @tool_rental = current_user.tool_rentals.build(tool_rental_params)
    @tool_rental.calculate_price
    @tool_rental.save!

    if current_user.billing_address.nil?
      current_user.create_billing_address(@tool_rental.renter_billing_address)
    end

    redirect_to [:choose_payment, @tool_rental]
  end

  def edit
    @tool_rental = current_user.tool_rentals.find(params[:id])
    if !@tool_rental.incomplete?
      redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id) and return
    end
  end

  def update
    @tool_rental = current_user.tool_rentals.incomplete.find(params[:id])
    @tool_rental.assign_attributes(tool_rental_params)
    @tool_rental.calculate_price
    @tool_rental.save!
    redirect_to [:choose_payment, @tool_rental]
  end

  def choose_payment
    @tool_rental = current_user.tool_rentals.find(params[:id])
    if !@tool_rental.incomplete?
      redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id) and return
    end
    @setup_intent = ToolRentalService.new.create_setup_intent(@tool_rental)
  end

  def payment_authorized
    @tool_rental = current_user.tool_rentals.find(params[:id])
    redirect_to [:choose_payment, @tool_rental] if params[:setup_intent].blank?

    success, error = ToolRentalService.new.payment_authorized(@tool_rental, params[:setup_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."
      redirect_to [:summary, @tool_rental]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @tool_rental]
    end
  end

  def change_payment
    @tool_rental = ToolRental.find(params[:id])
    redirect_to [:summary, @tool_rental] if !(@tool_rental.failed? && @tool_rental.approved?)

    @payment_intent = ToolRentalService.new.create_retry_intent(@tool_rental)
  end

  def payment_changed
    @tool_rental = ToolRental.find(params[:id])
    redirect_to [:summary, @tool_rental] if params[:payment_intent].blank?

    success, error = ToolRentalService.new.payment_retried(@tool_rental, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich authorisiert."
      redirect_to [:summary, @tool_rental]
    else
      flash[:error] = error
      redirect_to [:change_payment, @tool_rental]
    end
  end

  def summary
    @tool_rental = ToolRental.find(params[:id])
  end

  def cancel
    @tool_rental = current_user.tool_rentals.pending.find(params[:id])
    ToolRentalService.new.cancel(@tool_rental)
    redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id)
  end

  def approve
    @tool_rental = current_user.owned_tool_rentals.pending.find(params[:id])
    ToolRentalService.new.approve(@tool_rental)
    redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id)
  end

  def reject
    @tool_rental = current_user.owned_tool_rentals.pending.find(params[:id])
    ToolRentalService.new.reject(@tool_rental)
    redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id)
  end

  def confirm_return
    @tool_rental = current_user.owned_tool_rentals.return_pending.find(params[:id])
    ToolRentalService.new.confirm_return(@tool_rental)
    redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id)
  end

  def leave_rating
    @tool_rental = ToolRental.find(params[:id])

    if @tool_rental.owner == current_user
      @tool_rental.update(renter_rating: params[:rating])
      @tool_rental.renter.recalculate_rating
    elsif @tool_rental.renter == current_user
      @tool_rental.update(owner_rating: params[:rating])
      @tool_rental.owner.recalculate_rating
    end

    redirect_to messenger_url(thread_id: @tool_rental.user_message_thread.id)
  end

  private

  def initial_rental_params
    params.permit(:tool_offer_id, :rent_from, :rent_to)
  end

  def current_user_address_params
    {
      renter_name: current_user.billing_address&.full_name || current_user.full_name,
      renter_company: current_user.billing_address&.company,
      renter_address: current_user.billing_address&.street || current_user.address_street,
      renter_zip: current_user.billing_address&.zip || current_user.address_zip,
      renter_city: current_user.billing_address&.city || current_user.address_city,
    }
  end

  def tool_rental_params
    params.require(:tool_rental).permit(
      :tool_offer_id,
      :rent_from, :rent_to,
      :renter_name, :renter_address, :renter_zip, :renter_city,
    )
  end

end
