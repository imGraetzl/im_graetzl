class ToolOffersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :calculate_price]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @tool_offers = collection_scope.includes(:user)
    @tool_offers = filter_collection(@tool_offers)
    @tool_offers = @tool_offers.by_currentness.page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @tool_offer = ToolOffer.non_deleted.find(params[:id])
    @comments = @tool_offer.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @tool_offer = ToolOffer.new(current_user.slice(:first_name, :last_name, :iban))
  end

  def create
    @tool_offer = ToolOffer.new(tool_offer_params)
    @tool_offer.user_id = current_user.id
    set_address(@tool_offer, params[:feature])

    if @tool_offer.save
      ToolOfferMailer.tool_offer_published(@tool_offer).deliver_later
      @tool_offer.create_activity(:create, owner: @tool_offer.user)
      redirect_to @tool_offer
    else
      render 'new'
    end
  end

  def edit
    @tool_offer = current_user.tool_offers.non_deleted.find(params[:id])
  end

  def update
    @tool_offer = current_user.tool_offers.non_deleted.find(params[:id])
    @tool_offer.assign_attributes(tool_offer_params)
    set_address(@tool_offer) if @tool_offer.address.changed?

    if @tool_offer.save
      redirect_to @tool_offer
    else
      render 'edit'
    end
  end

  def update_status
    @tool_offer = current_user.tool_offers.non_deleted.find(params[:id])
    @tool_offer.update(status: params[:status])
    redirect_back(fallback_location: tool_offers_user_path)
  end

  def calculate_price
    @tool_offer = ToolOffer.find(params[:id])
    @tool_rental = @tool_offer.tool_rentals.build(params.permit(:rent_from, :rent_to))
    head :bad_request and return if @tool_rental.rent_from.blank? || @tool_rental.rent_to.blank?
    @tool_rental.calculate_price
  end

  def destroy
    @tool_offer = current_user.tool_offers.find(params[:id])
    @tool_offer.deleted!
    redirect_to tool_offers_user_path
  end

  private

  def collection_scope
    if params[:user_id].present?
      ToolOffer.enabled.where(user_id: params[:user_id])
    else
      ToolOffer.enabled
    end
  end

  def filter_collection(collection)
    district_ids = params[:district_ids]&.select(&:present?)
    if district_ids.present?
      graetzl_ids = Graetzl.joins(:districts).where(districts: {id: district_ids}).distinct.pluck(:id)
      collection = collection.where(graetzl_id: graetzl_ids)
    end

    if params[:category_id].present?
      collection = collection.where(tool_category_id: params[:category_id])
    end

    if params[:query].present?
      collection = collection.where("title ILIKE :q OR description ILIKE :q", q: "%#{params[:query]}%")
    end

    collection
  end

  def tool_offer_params
    params.require(:tool_offer).permit(
      :title, :description, :brand, :model, :status, :keyword_list,
      :value_up_to, :serial_number, :known_defects,
      :price_per_day, :two_day_discount, :weekly_discount,
      :tool_category_id, :tool_subcategory_id, :location_id,
      :cover_photo, :remove_cover_photo,
      :first_name, :last_name, :iban,
      images_attributes: [:id, :file, :_destroy],
      address_attributes: [
        :id, :street_name, :street_number, :zip, :city
      ],
    )
  end

  def set_address(tool_offer, json = nil)
    if json
      resolver = AddressResolver.from_json(json)
      return if !resolver.valid?
      tool_offer.build_address(resolver.address_fields)
      tool_offer.graetzl = resolver.graetzl
    elsif tool_offer.address
      resolver = AddressResolver.from_street(tool_offer.address.street)
      return if !resolver.valid?
      tool_offer.address.assign_attributes(resolver.address_fields)
      tool_offer.graetzl = resolver.graetzl
    end
  end

end
