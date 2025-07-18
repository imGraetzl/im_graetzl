class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.registered.find(params[:id])
    return if redirect_to_region?(@user)

    @graetzl = @user.graetzl
    @wall_comments = @user.wall_comments.includes(:user, :images).order(created_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.registered.find(params[:id])
    if @user.update(user_params)
      bypass_sign_in @user

      if user_params[:favorite_graetzl_ids].present?
        redirect_back fallback_location: @user, notice: "Deine Favoriten wurden gespeichert!"

      elsif user_params[:billing_address_attributes].present?
        redirect_back fallback_location: @user, notice: "Deine Rechnungsdaten wurden gespeichert"
      else
        redirect_to @user, notice: "Profil gespeichert!"
      end

    else
      render :edit
    end
  end

  def rooms
    @user = current_user
    @rooms = @user.room_offers.in(current_region) + @user.room_demands.in(current_region)
    @owned_room_rentals = current_user.owned_room_rentals.in(current_region).initialized.includes(:room_offer, :user, :user_message_thread)
    @room_rentals = current_user.room_rentals.in(current_region).initialized.includes(:user_message_thread, room_offer: :user)
  end

  def energies
    @user = current_user
    @energies = @user.energy_offers.in(current_region) + @user.energy_demands.in(current_region)
  end

  def zuckerls
    @zuckerls = current_user.zuckerls.initialized.in(current_region).order(created_at: :desc)
    @subscription = current_user.subscription
  end

  def locations
    @locations = current_user.locations.in(current_region).includes(:user)
  end

  def coop_demands
    @coop_demands = current_user.coop_demands.in(current_region).includes(:user)
  end

  def meetings
    @user = current_user
  end

  def crowd_campaigns
    @crowd_campaigns = current_user.crowd_campaigns.in(current_region).includes(:user)
  end

  def room_boosters
    @room_boosters = current_user.room_boosters.initialized.in(current_region).includes(:user)
  end

  def groups
    @groups = current_user.groups.in(current_region).includes(:room_offer, :discussion_categories)
  end

  def favorite_graetzls
    @user = current_user
    @graetzls = current_region.graetzls.sort_by! { |g| g.zip.to_i }.reverse
  end

  def favorites
    @user = current_user
  end

  def subscription
    if current_user.subscribed?
      @subscription = current_user.subscription
    else
      @subscription = current_user.subscriptions.initialized.last
    end
  end

  def billing_address
    @user = current_user
  end

  def payment_method
    @user = current_user
    @setup_intent = UserService.new.create_setup_intent(current_user)
  end

  def payment_authorized
    redirect_to payment_method_user_path if params[:setup_intent].blank?

    success, error = UserService.new.payment_authorized(current_user, params[:setup_intent])

    if success
      flash[:notice] = "Deine Zahlungsmethode wurde erfolgreich aktualisiert."
    else
      flash[:error] = error
    end

    redirect_to payment_method_user_path

  end

  def tooltip
    head :ok and return if browser.bot? && !request.format.js?
    @user = User.registered.find(params[:id])
    render layout: false
  end

  private

  def user_params
    params[:user].delete(:password) if params[:user][:password].blank?
    params.require(:user).permit(:email,
      :password,
      :first_name,
      :last_name,
      :website,
      :bio,
      :newsletter,
      :business,
      :avatar, :remove_avatar,
      :cover_photo, :remove_cover_photo,
      :location_category_id,
      :iban,
      :address_street, :address_coords, :address_zip, :address_city, :graetzl_id,
      favorite_graetzl_ids: [],
      billing_address_attributes: [
        :first_name, :last_name, :street, :zip, :city, :country, :company, :vat_id
      ],
      business_interest_ids: [],
    )
  end
end
