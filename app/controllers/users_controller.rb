class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @graetzl = @user.graetzl
    @wall_comments = @user.wall_comments.includes(:user, :images).order(created_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      bypass_sign_in @user

      if user_params[:favorite_graetzl_ids].present?
        redirect_back fallback_location: @user, notice: "Deine Favoriten wurden gespeichert!"
      else
        redirect_to @user, notice: "Profil gespeichert!"
      end

    else
      render :edit
    end
  end

  def rooms
    @user = current_user
    @rooms = @user.room_offers.in(current_region) + @user.room_demands.in(current_region) + @user.room_calls.in(current_region)
    @owned_room_rentals = current_user.owned_room_rentals.in(current_region).submitted.includes(:room_offer, :user, :user_message_thread)
    @room_rentals = current_user.room_rentals.in(current_region).submitted.includes(:user_message_thread, room_offer: :user)
  end

  def tools
    @tools = current_user.tool_offers.in(current_region).non_deleted + current_user.tool_demands.in(current_region)
    @owned_tool_rentals = current_user.owned_tool_rentals.in(current_region).submitted.includes(:tool_offer, :user, :user_message_thread )
    @tool_rentals = current_user.tool_rentals.submitted.in(current_region).includes(:user_message_thread, tool_offer: :user)
  end

  def zuckerls
    @zuckerls = Zuckerl.where(location: current_user.locations).in(current_region).
      where.not(aasm_state: :cancelled).order(created_at: :desc)
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

  def groups
    @groups = current_user.groups.in(current_region).includes(:room_offer, :room_call, :discussion_categories)
  end

  def favorite_graetzls
    @user = current_user
    @graetzls = current_region.graetzls.sort_by(&:zip).reverse
  end

  def tooltip
    head :ok and return if browser.bot? && !request.format.js?
    @user = User.find(params[:id])
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
