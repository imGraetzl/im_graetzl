class GoingTosController < ApplicationController
  before_action :authenticate_user!, except: [:new]

  def new
    read_params
    render 'login' and return if !user_signed_in?
  end

  def choose_payment
    read_params
    if params[:source].present?
      @source_status = Stripe::Source.retrieve(params[:source]).status
    end
  end

  def summary
    read_params
    if params[:stripe_payment_intent_id].present?
      intent = Stripe::PaymentIntent.retrieve(params[:stripe_payment_intent_id])
      @card = intent.charges.data.first.payment_method_details.card
    end
  end

  def initiate_card_payment
  end

  def initiate_eps_payment
  end

  def create
    read_params

    @going_to = current_user.going_tos.build(going_to_params)
    @going_to.assign_attributes(
    )
    @going_to.save!

  end

  private

  def going_to_params
    params.permit(
      :meeting_id, :meeting_additional_date_id,
      :company, :full_name, :street, :zip, :city,
      :stripe_payment_intent_id, :stripe_source_id, :payment_method,
    )
  end

  def klarna_params
    params.permit(:first_name, :last_name, :email, :address, :zip, :city)
  end

  def eps_params
    params.permit(:full_name)
  end

  def read_params
    @meeting = Meeting.find(params[:meeting_id])
    if params[:meeting_additional_date_id].present?
      @meeting_additional_date = MeetingAdditionalDate.find(params[:meeting_additional_date_id])
      @starts_at_date = @meeting_additional_date.starts_at_date
      @display_starts_at_date = @meeting_additional_date.display_starts_at_date
    else
      @starts_at_date = @meeting.starts_at_date
      @display_starts_at_date = @meeting.display_starts_at_date
    end
  end

end
