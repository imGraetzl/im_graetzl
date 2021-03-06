class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @graetzl = Graetzl.find_by_slug(params[:graetzl_id])
    redirect_to([@user.graetzl, @user], status: 301) and return if wrong_graetzl?(@user, @graetzl)
    @wall_comments = @user.wall_comments.includes(:user, :images).order(created_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      bypass_sign_in @user
      redirect_to [@user.graetzl, @user], notice: "Profil gespeichert!"
    else
      render :edit
    end
  end

  def rooms
    @user = current_user
    @rooms = RoomOffer.where(user_id: @user) + RoomDemand.where(user_id: @user) + RoomCall.where(user_id: @user)
    @owned_room_rentals = current_user.owned_room_rentals.submitted.includes(:room_offer, :user, :user_message_thread )
    @room_rentals = current_user.room_rentals.submitted.includes(:user_message_thread, room_offer: :user)
  end

  def tool_offers
    @tool_offers = current_user.tool_offers.non_deleted
    @owned_tool_rentals = current_user.owned_tool_rentals.submitted.includes(:tool_offer, :user, :user_message_thread )
    @tool_rentals = current_user.tool_rentals.submitted.includes(:user_message_thread, tool_offer: :user)
  end

  def zuckerls
    @zuckerls = Zuckerl.where(location: current_user.locations).
      where.not(aasm_state: :cancelled).order(created_at: :desc)
  end

  def locations
    @locations = current_user.locations.includes(:user)
  end

  def meetings
    @user = current_user
  end

  def groups
    @groups = current_user.groups.includes(:room_offer, :room_call, :discussion_categories)
  end

  def tooltip
    head :ok and return if browser.bot? && !request.format.js?
    @user = User.find(params[:id])
    render layout: false
  end

  private

  def wrong_graetzl?(user, graetzl)
    graetzl.nil? || user.graetzl != graetzl
  end

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
      billing_address_attributes: [
        :first_name, :last_name, :street, :zip, :city, :country, :company, :vat_id
      ],
      business_interest_ids: [],
    )
  end
end
