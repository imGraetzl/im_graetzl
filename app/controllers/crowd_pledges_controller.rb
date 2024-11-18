class CrowdPledgesController < ApplicationController
  before_action :load_active_campaign, only: [:new, :create, :login, :calculate_price, :choose_amount]
  before_action :manage_guest_user_session

  def new
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.assign_attributes(current_user_params) if current_or_session_guest_user
    @crowd_pledge.calculate_price
  end

  def create
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(crowd_pledge_params)

    if @crowd_pledge.crowd_reward&.fully_claimed?
      redirect_to @crowd_pledge.crowd_campaign, notice: "Dieses Dankeschön ist nicht mehr verfügbar."
    end

    @crowd_pledge.calculate_price
    @crowd_pledge.status = "incomplete"
    @crowd_pledge.user_agent = user_agent

    if @crowd_pledge.save
      # Only create or find the user after the pledge is saved successfully
      user = current_or_guest_user_by(crowd_pledge_params['email'])
      @crowd_pledge.update_column(:user_id, user&.id) # Direct update to avoid callbacks or timestamps
  
      # Update Guest User if User Data has changed
      update_guest_user?(user, @crowd_pledge) if user&.guest?
      redirect_to [:choose_payment, @crowd_pledge]
    else
      render :new
    end
  end

  def calculate_price
    head :ok and return if browser.bot? && !request.format.js?
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def choose_amount
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def login
    @crowd_pledge = @crowd_campaign.crowd_pledges.build(initial_pledge_params)
    @crowd_pledge.calculate_price
  end

  def choose_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:summary, @crowd_pledge] and return if !@crowd_pledge.incomplete?

    @crowd_pledge.calculate_price
    @setup_intent = CrowdPledgeService.new.create_setup_intent(@crowd_pledge)
  end

  def payment_authorized
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:choose_payment, @crowd_pledge] if params[:setup_intent].blank?

    success, error = CrowdPledgeService.new.payment_authorized(@crowd_pledge, params[:setup_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."
      redirect_to [:summary, @crowd_pledge]
    else
      flash[:error] = error
      redirect_to [:choose_payment, @crowd_pledge]
    end
  end

  def summary
    @crowd_pledge = CrowdPledge.find(params[:id])
  end

  def pledge_comment
    @crowd_pledge = CrowdPledge.find(params[:id])
    @comment = Comment.new(comment_params)
    @comment.user = @crowd_pledge.user

    if @comment.save
      @crowd_pledge.update(comment_id: @comment.id)
      ActionProcessor.track(@crowd_pledge.crowd_campaign, :pledge_comment, @comment)
    end
    render 'crowd_pledges/new/pledge_comment'
  end

  def details
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to @crowd_pledge.crowd_campaign if @crowd_pledge.incomplete?
  end

  def change_payment
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:details, @crowd_pledge] if !@crowd_pledge.failed?

    if @crowd_pledge.crowd_campaign.payment_closed?
      flash[:notice] = "Sorry, die Kampagne wurde bereits geschlossen und kann daher nicht mehr unterstützt werden."
      redirect_to [:details, @crowd_pledge]
    end

    @payment_intent = CrowdPledgeService.new.create_retry_intent(@crowd_pledge)
  end

  def payment_changed
    @crowd_pledge = CrowdPledge.find(params[:id])
    redirect_to [:summary, @crowd_pledge] if params[:payment_intent].blank?

    success, error = CrowdPledgeService.new.payment_retried(@crowd_pledge, params[:payment_intent])

    if success
      flash[:notice] = "Deine Zahlung wurde erfolgreich autorisiert."
      redirect_to [:summary, @crowd_pledge]
    else
      flash[:error] = error
      redirect_to [:change_payment, @crowd_pledge]
    end
  end

  def unsubscribe
    @crowd_pledge = CrowdPledge.find(params[:id])
    if @crowd_pledge.guest_newsletter? && params[:unsubscribe_code].to_i == @crowd_pledge.unsubscribe_code
      CrowdPledge.guest_newsletter.where(email: @crowd_pledge.email).update_all(guest_newsletter: false)
      flash[:notice] = "Deine Crowdfunding E-Mails wurden erfolgreich abbestellt."
    elsif !@crowd_pledge.guest_newsletter?
      flash[:notice] = "Du bist bereits von den E-Mails abgemeldet."
    else
      flash[:notice] = "Der Abmeldelink ist leider ungültig."
    end
    redirect_to [:details, @crowd_pledge]
  end

  private

  def user_agent
    return {
      browser_name: "#{browser.name}",
      browser_full_version: "#{browser.full_version}",
      browser_platform: "#{browser.platform}",
      browser_platform_id: "#{browser.platform.id}",
      browser_platform_name: "#{browser.platform.name}",
      browser_platform_version: "#{browser.platform.version}",
      browser_device_id: "#{browser.device.id}",
      browser_device_name: "#{browser.device.name}",
    }
  end

  def load_active_campaign
    redirect_to root_url and return if params[:crowd_campaign_id].blank?

    @crowd_campaign = CrowdCampaign.find(params[:crowd_campaign_id])

    if !@crowd_campaign.funding?
      redirect_back fallback_location: @crowd_campaign, flash: {
        error: "Die Kampagne befindet sich gerade nicht im Finanzierungszeitraum (#{@crowd_campaign.runtime}) und kann daher jetzt nicht unterstützt werden."
      }
    end
  end

  def initial_pledge_params
    params.permit(:crowd_reward_id, :donation_amount, :answer)
  end

  def current_user_params
    {
      email: current_or_session_guest_user.email,
      contact_name: current_or_session_guest_user.full_name,
      address_street: current_or_session_guest_user.address_street,
      address_zip: current_or_session_guest_user.address_zip,
      address_city: current_or_session_guest_user.address_city,
    }
  end

  def crowd_pledge_params
    params.require(:crowd_pledge).permit(
      :crowd_reward_id, :donation_amount, :anonym, :terms, :guest_newsletter,
      :email, :contact_name, :address_street, :address_zip, :address_city, :answer,
      :user_agent
    )
  end

  def comment_params
    params.require(:comment).permit(:content, :commentable_id, :commentable_type)
  end

  def guest_user_params
    { 
      email: crowd_pledge_params['email'],
      first_name: crowd_pledge_params['contact_name']&.split&.first,
      last_name: crowd_pledge_params['contact_name']&.split(' ')[1..-1]&.join(' '),
      address_street: crowd_pledge_params['address_street'],
      address_zip: crowd_pledge_params['address_zip'],
      address_city: crowd_pledge_params['address_city'],
      business: false,
      origin: request.path,
      region_id: current_region.id,
    }
  end

  def update_guest_user?(guest_user, crowd_pledge)
    begin
      changes = {}
      changes[:first_name] = crowd_pledge.first_name if guest_user.first_name != crowd_pledge.first_name
      changes[:last_name] = crowd_pledge.last_name if guest_user.last_name != crowd_pledge.last_name
      changes[:address_street] = crowd_pledge.address_street if guest_user.address_street != crowd_pledge.address_street
      changes[:address_zip] = crowd_pledge.address_zip if guest_user.address_zip != crowd_pledge.address_zip
      changes[:address_city] = crowd_pledge.address_city if guest_user.address_city != crowd_pledge.address_city

      if changes.present?
        guest_user.update_columns(changes)
        Rails.logger.info "Guest user with ID: #{guest_user.id} was successfully updated with changes: #{changes}. Via CrowdPledge ID: #{crowd_pledge.id}"
        true
      else
        false
      end
    rescue => e
      Rails.logger.error "An error occurred while updating guest user with ID: #{guest_user.id}. Via CrowdPledge ID: #{crowd_pledge.id}. Error: #{e.message}"
      false
    end
  end

end
