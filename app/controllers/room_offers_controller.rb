class RoomOffersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :reactivate, :calculate_price, :available_hours]

  def show
    @room_offer = RoomOffer.includes(:images).find(params[:id])
    return if redirect_to_region?(@room_offer)
    set_schema_org_object(SchemaOrg::RoomOffer.new(@room_offer, host: request.base_url))
    @comments = @room_offer.comments.includes(:user, :images, comments: [:user, :images]).order(created_at: :desc)
    @room_offer_prices = @room_offer.room_offer_prices.order(:amount).to_a
  end

  def select
  end

  def new
    @room_offer = RoomOffer.new
    @room_offer.room_offer_prices.build
    @room_offer.assign_attributes(current_user.slice(:first_name, :last_name, :email, :website))
    @room_offer.graetzl = user_home_graetzl
  end

  def create
    @room_offer = RoomOffer.new(room_offer_params)
    @room_offer.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @room_offer.region_id = current_region.id
    @room_offer.activate

    if @room_offer.save
      current_user.update(user_params) if params[:user].present?
      RoomMailer.room_offer_published(@room_offer).deliver_later
      ActionProcessor.track(@room_offer, :create)
      redirect_to @room_offer
    else
      render 'new'
    end
  end

  def edit
    @room_offer = current_user.room_offers.find(params[:id])
  end

  def update
    @room_offer = current_user.room_offers.find(params[:id])
    if @room_offer.update(room_offer_params)
      current_user.update(user_params) if params[:user].present?
      ActionProcessor.track(@room_offer, :update) if @room_offer.refresh_activity

      if params[:tab].present?
        flash[:notice] = "Deine Änderungen wurden gespeichert. #{view_context.link_to 'Raumteiler ansehen', @room_offer}"
        redirect_to edit_room_offer_path(@room_offer, :initTab => params[:tab])
      else
        redirect_to @room_offer
      end

    else
      render 'edit'
    end
  end

  def update_status
    @room_offer = current_user.room_offers.find(params[:id])
    @room_offer.update(status: params[:status])
    ActionProcessor.track(@room_offer, :update) if @room_offer.refresh_activity
    flash[:notice] = t("activerecord.attributes.room_offer.status_message.#{@room_offer.status}")
    redirect_back(fallback_location: rooms_user_path)
  end

  def reactivate
    @room_offer = RoomOffer.find_by_token_for(:activation, params[:activation_token])
    if @room_offer&.disabled?
      @room_offer.update(status: :enabled)
      ActionProcessor.track(@room_offer, :update) if @room_offer.refresh_activity
      flash[:notice] = "Dein Raumteiler wurde erfolgreich verlängert!"
    elsif @room_offer&.enabled?
      flash[:notice] = "Dein Raumteiler ist bereits aktiv."
    else
      flash[:notice] = "Der Aktivierungslink ist leider ungültig. Log dich ein um deinen Raumteiler zu aktivieren."
    end
    redirect_to RoomOffer.find(params[:id])
  end

  def rental_timetable
    @room_offer = current_user.room_offers.find(params[:id])
    @availability = RoomRentalAvailability.new(@room_offer)
    month = params[:month].present? ? Date.parse(params[:month]) : Date.today
    @date_range = month.beginning_of_month..month.end_of_month
  end

  def available_hours
    head :ok and return if browser.bot? && !request.format.js?
    
    @room_offer = RoomOffer.find(params[:id])
    @availability = RoomRentalAvailability.new(@room_offer)
    render json: @availability.available_hours(params[:rent_date], params[:hour_from])
  end

  def calculate_price
    head :ok and return if browser.bot? && !request.format.js?
    @room_offer = RoomOffer.find(params[:id])
    @room_rental = RoomRental.new(
      room_offer: @room_offer,
      room_rental_slots_attributes: [params.permit(:rent_date, :hour_from, :hour_to)],
    )
    @room_rental.calculate_price
  end

  def toggle_waitlist
    @room_offer = RoomOffer.find(params[:id])
    if @room_offer.waiting_users.include?(current_user)
      @room_offer.room_offer_waiting_users.where(user_id: current_user.id).delete_all
      flash[:notice] = 'Du wurdest von der Warteliste entfernt.'
    else
      @room_offer.room_offer_waiting_users.create(user_id: current_user.id)
      RoomMailer.waiting_list_updated(@room_offer, current_user).deliver_later
      flash[:notice] = "Du stehst nun auf der Warteliste und #{@room_offer.first_name} #{@room_offer.last_name} wurde darüber per E-Mail informiert."
    end
    redirect_to @room_offer
  end

  def add_to_wailist
  end

  def remove_from_waitlist
    @room_offer = RoomOffer.find(params[:id])
    user = User.find(params[:user])
    if current_user == user || current_user.id == @room_offer.user_id
      @room_offer.room_offer_waiting_users.where(user_id: user.id).delete_all
      redirect_to @room_offer
      flash[:notice] = "#{user.full_name} wurde von der Warteliste entfernt."
    else
      redirect_to @room_offer
      flash[:notice] = 'Keine Rechte'
    end
  end

  def destroy
    @room_offer = current_user.room_offers.find(params[:id])
    @room_offer.destroy
    redirect_to rooms_user_path
  end

  private

  def room_offer_params
    params
      .require(:room_offer)
      .permit(
        :offer_type,
        :slogan,
        :rented_area,
        :total_area,
        :room_description,
        :owner_description,
        :tenant_description,
        :wants_collaboration,
        :cover_photo,
        :remove_cover_photo,
        :avatar,
        :activation_token,
        :remove_avatar,
        :general_availability,
        :rental_enabled,
        :last_activated_at,
        :graetzl_id,
        :address_street, :address_coords, :address_city, :address_zip, :address_description,
        :first_name, :last_name, :website, :email, :phone, :location_id,
        images_attributes: [:id, :file, :_destroy],
        room_offer_prices_attributes: [
          :id, :name, :amount, :_destroy
        ],
        room_rental_price_attributes: [
          :id, :name, :price_per_hour, :minimum_rental_hours, :four_hour_discount, :eight_hour_discount,
          :_destroy
        ],
        room_offer_availability_attributes: [
          :id, *(0..6).map{|i| :"day_#{i}_from"}, *(0..6).map{|i| :"day_#{i}_to"}
        ].flatten,
        room_category_ids: [],
    ).merge(
      keyword_list: [params[:suggested_keywords], params[:custom_keywords]].join(", ")
    )
  end

  def user_params
    params.require(:user).permit(
      :iban,
      billing_address_attributes: [
        :id, :first_name, :last_name, :street, :zip, :city, :country, :company, :vat_id,
      ],
    )
  end

end
