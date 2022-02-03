class CrowdfundingsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @crowdfundings = collection_scope.in(current_region).includes(:user)
    @crowdfundings = filter_collection(@crowdfundings)
    @crowdfundings = @crowdfundings.by_currentness.page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @crowdfunding = Crowdfunding.in(current_region).find(params[:id])
    @comments = @crowdfunding.comments.includes(:user, :images).order(created_at: :desc)
  end

  def new
    @crowdfunding = Crowdfunding.new(current_user_address_params)
  end

  def create
    @crowdfunding = Crowdfunding.new(crowdfunding_params)
    @crowdfunding.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @crowdfunding.region_id = current_region.id
    @crowdfunding.clear_address if params[:no_address] == 'true'

    if @crowdfunding.save
      #CrowdfundingMailer.crowdfunding_published(@crowdfunding).deliver_later
      #ActionProcessor.track(@crowdfunding, :create)
      redirect_to description_crowdfunding_path(@crowdfunding)
    else
      render :new
    end
  end

  def edit
    @crowdfunding = current_user.crowdfundings.find(params[:id])
  end

  def description
    @crowdfunding = current_user.crowdfundings.find(params[:id])
  end

  def finance
    @crowdfunding = current_user.crowdfundings.find(params[:id])
  end

  def rewards
    @crowdfunding = current_user.crowdfundings.find(params[:id])
  end

  def media
    @crowdfunding = current_user.crowdfundings.find(params[:id])
  end

  def finish
    @crowdfunding = current_user.crowdfundings.find(params[:id])
  end

  def update
    @crowdfunding = current_user.crowdfundings.find(params[:id])
    @crowdfunding.clear_address if params[:no_address] == 'true'
    @crowdfunding.status = params[:status] if params[:status]

    if @crowdfunding.update(crowdfunding_params)
      if params[:page]
        redirect_to params[:page]
      else
        redirect_back fallback_location: edit_crowdfunding_path(@crowdfunding), notice: 'Deine Änderungen wurden gespeichert.'
      end
    else
      render :edit
    end
  end

  def destroy
    @crowdfunding = current_user.crowdfundings.find(params[:id])
    @crowdfunding.destroy

    redirect_to crowdfundings_user_path
  end

  private

  def collection_scope
    if params[:user_id].present?
      Crowdfunding.approved.where(user_id: params[:user_id])
    else
      Crowdfunding.approved
    end
  end

  def filter_collection(collection)
    graetzl_ids = params.dig(:filter, :graetzl_ids)

    if params[:category_id].present?
      collection = collection.where(crowd_category: params[:category_id])
    end

    if params[:favorites].present? && current_user
      collection = collection.where(graetzl_id: current_user.followed_graetzl_ids)
    elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
      collection = collection.where(graetzl_id: graetzl_ids)
    end

    collection
  end

  def current_user_address_params
    {
      graetzl_id: current_user.graetzl_id,
      contact_email: current_user.email,
      contact_website: current_user.website,
      contact_name: current_user.billing_address&.full_name || current_user.full_name,
      contact_company: current_user.billing_address&.company,
      contact_address: current_user.billing_address&.street || current_user.address_street,
      contact_zip: current_user.billing_address&.zip || current_user.address_zip,
      contact_city: current_user.billing_address&.city || current_user.address_city,
    }
  end

  def crowdfunding_params
    params
      .require(:crowdfunding)
      .permit(
        :title, :slogan, :description, :support_description, :about_description,
        :startdate, :runtime, :billable,
        :funding_1_amount, :funding_1_description, :funding_2_amount, :funding_2_description,
        :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
        :location_id, :room_offer_id, :crowd_benefit_id,
        :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
        :cover_photo, :remove_cover_photo, :video,
        images_attributes: [:id, :file, :_destroy],
        crowd_rewards_attributes: [
          :id, :amount, :limit, :title, :description, :delivery_weeks, :delivery_address_required, :question, :avatar, :remove_avatar, :_destroy
        ],
        crowd_donations_attributes: [
          :id, :donation_type, :limit, :title, :description, :question, :startdate, :enddate, :_destroy
        ],
        crowd_category_ids: [],
    )
  end
end
