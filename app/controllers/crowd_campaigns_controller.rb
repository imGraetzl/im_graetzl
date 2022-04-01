class CrowdCampaignsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :supporters, :posts, :comments]

  def index
    head :ok and return if browser.bot? && !request.format.js?
    @crowd_campaigns = collection_scope.in(current_region).includes(:user)
    @crowd_campaigns = filter_collection(@crowd_campaigns)
    @crowd_campaigns = @crowd_campaigns.by_currentness.page(params[:page]).per(params[:per_page] || 15)
  end

  def show
    @crowd_campaign = CrowdCampaign.in(current_region).find(params[:id])
    @crowd_pledges = @crowd_campaign.crowd_pledges
    @preview = params[:preview] == 'true' ?  true : false
    show_status_message?
  end

  def new
    @crowd_campaign = CrowdCampaign.new(current_user_address_params)
  end

  def create
    @crowd_campaign = CrowdCampaign.new(editable_campaign_params)
    @crowd_campaign.user_id = current_user.admin? ? params[:user_id] : current_user.id
    @crowd_campaign.region_id = current_region.id
    @crowd_campaign.clear_address if params[:no_address] == 'true'

    if @crowd_campaign.save
      redirect_to edit_description_crowd_campaign_path(@crowd_campaign)
    else
      render :new
    end
  end
  def edit
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    return redirect_to edit_crowd_campaign_path(@crowd_campaign) if params[:id] != @crowd_campaign.slug
    form_status_message?
  end

  def edit_description
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    return redirect_to edit_description_crowd_campaign_path(@crowd_campaign) if params[:id] != @crowd_campaign.slug
    form_status_message?
  end

  def edit_finance
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    form_status_message?
  end

  def edit_rewards
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    form_status_message?
  end

  def edit_media
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    form_status_message?
  end

  def edit_finish
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    form_status_message?
  end

  def status
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    @crowd_pledges = @crowd_campaign.crowd_pledges.authorized.order(created_at: :desc)
    form_status_message?
  end

  def download_supporters
    respond_to do |format|
      format.xlsx do
        @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
        @crowd_pledges = @crowd_campaign.crowd_pledges.authorized.order(created_at: :desc)
        render xlsx: 'UnterstützerInnen', template: 'crowd_campaigns/crowd_pledges/crowd_pledges'
      end
    end
  end

  def posts
    @crowd_campaign = CrowdCampaign.in(current_region).find(params[:id])
    @posts = @crowd_campaign.crowd_campaign_posts.includes(:images, :comments).order(created_at: :desc)
  end

  def comments
    @crowd_campaign = CrowdCampaign.in(current_region).find(params[:id])
    @comments = @crowd_campaign.comments.includes(:user, :images).order(created_at: :desc)
  end

  def supporters
    @crowd_campaign = CrowdCampaign.in(current_region).find(params[:id])
    @supporters = @crowd_campaign.crowd_pledges.authorized.visible.order(created_at: :desc)
  end

  def update
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    @crowd_campaign.clear_address if params[:no_address] == 'true'

    if @crowd_campaign.editable?
      @crowd_campaign.assign_attributes(editable_campaign_params)
    else
      @crowd_campaign.assign_attributes(noneditable_campaign_params)
    end

    if @crowd_campaign.save
      if params[:page]
        redirect_to params[:page]
      elsif params[:submit_for_approve] && !@crowd_campaign.all_steps_finished?
        redirect_back fallback_location: edit_crowd_campaign_path(@crowd_campaign), notice: 'Deine Crowdfundingkampagne konnte noch nicht zur Freigabe eingereicht werden. Bitte fülle alle Felder aus, bis alle Schritte mit einem Haken gekennzeichnet sind.'
      elsif params[:submit_for_approve] && @crowd_campaign.all_steps_finished?
        @crowd_campaign.status = :pending
        @crowd_campaign.save
        CrowdCampaignMailer.pending(@crowd_campaign).deliver_later
        redirect_to status_crowd_campaign_path(@crowd_campaign)
      else
        redirect_back fallback_location: edit_crowd_campaign_path(@crowd_campaign), notice: "Deine Änderungen wurden gespeichert. | #{ActionController::Base.helpers.link_to('Kampagne ansehen', crowd_campaign_path(@crowd_campaign))}"
      end
    else
      render :edit
    end

  end

  def add_post
    @crowd_campaign = fetch_user_crowd_campaign(params[:id])
    @crowd_campaign_post = @crowd_campaign.crowd_campaign_posts.build(crowd_campaign_post_params)
    if @crowd_campaign_post.save
      ActionProcessor.track(@crowd_campaign, :post, @crowd_campaign_post)
    end
    render 'crowd_campaigns/crowd_campaign_posts/add'
  end

  def remove_post
    @crowd_campaign = fetch_user_crowd_campaign(params[:id])
    @crowd_campaign_post = @crowd_campaign.crowd_campaign_posts.find(params[:post_id])
    @crowd_campaign_post.destroy
    render 'crowd_campaigns/crowd_campaign_posts/remove'
  end

  def comment_post
    @crowd_campaign = CrowdCampaign.find(params[:id])
    @crowd_campaign_post = @crowd_campaign.crowd_campaign_posts.find(params[:post_id])
    @comment = @crowd_campaign_post.comments.new(crowd_campaign_comment_params)
    @comment.user = current_user
    if @comment.save
      ActionProcessor.track(@crowd_campaign_post, :comment, @comment)
    end
    render 'crowd_campaigns/crowd_campaign_posts/comment'
  end

  def destroy
    @crowd_campaign = current_user.crowd_campaigns.find(params[:id])
    @crowd_campaign.destroy
    redirect_to crowd_campaigns_user_path
  end

  private

  def fetch_user_crowd_campaign(id)
    current_user.crowd_campaigns.find(id)
  end

  def form_status_message?
    flash.now[:alert] = "Deine Kampagne wird gerade überprüft. Du erhältst eine Nachricht sobald sie genehmnigt wurde. | #{ActionController::Base.helpers.link_to('Kampagne ansehen', crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.pending?
    flash.now[:alert] = "Deine Kampagne wurde genehmigt und läuft ab #{@crowd_campaign.runtime} | #{ActionController::Base.helpers.link_to('Kampagne ansehen', crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.approved?
    flash.now[:alert] = "Deine Kampagne läuft gerade und kann daher nur mehr eingeschränkt bearbeitet werden. | #{ActionController::Base.helpers.link_to('Kampagne ansehen', crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.funding?
    flash.now[:alert] = "Deine Kampagne ist abgeschlossen | #{ActionController::Base.helpers.link_to('Kampagne ansehen', crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.completed?
  end

  def show_status_message?
    if @crowd_campaign.user == current_user
      flash.now[:alert] = "Deine Kampagne ist noch im Bearbeitungsmodus. | #{ActionController::Base.helpers.link_to('Kampagne bearbeiten', edit_crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.draft?
      flash.now[:alert] = "Deine Kampagne wird überprüft. Du erhältst eine Nachricht sobald sie genehmnigt wurde. | #{ActionController::Base.helpers.link_to('Zum Kampagnen-Setup', edit_crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.pending?
      flash.now[:alert] = "Deine Kampagne wurde genehmigt und läuft ab #{@crowd_campaign.runtime}. | #{ActionController::Base.helpers.link_to('Zum Kampagnen-Setup', edit_crowd_campaign_path(@crowd_campaign))}" if @crowd_campaign.approved?
    else
      flash.now[:alert] = "Kampagnen Voransicht - Diese Kampagne ist noch in Bearbeitung." if @crowd_campaign.draft? || @crowd_campaign.pending?
      flash.now[:alert] = "Kampagnen Voransicht - Diese Kampagne läuft von #{@crowd_campaign.runtime}." if @crowd_campaign.approved?
    end
  end

  def collection_scope
    if params[:user_id].present?
      CrowdCampaign.funding.where(user_id: params[:user_id])
    else
      CrowdCampaign.scope_public
    end
  end

  def filter_collection(collection)
    graetzl_ids = params.dig(:filter, :graetzl_ids)
    crowd_category_ids = params.dig(:filter, :crowd_category_ids)

    if crowd_category_ids.present? && crowd_category_ids.any?(&:present?)
      collection = collection.joins(:crowd_categories).where(crowd_categories: {id: crowd_category_ids}).distinct
    end

    # Always show ALL Crowd Campaigns
    #if params[:favorites].present? && current_user
    #  collection = collection.where(graetzl_id: current_user.followed_graetzl_ids)
    #elsif graetzl_ids.present? && graetzl_ids.any?(&:present?)
    #  collection = collection.where(graetzl_id: graetzl_ids)
    #end

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

  def crowd_campaign_post_params
    params.require(:crowd_campaign_post).permit(
      :title, :content, images_attributes: [:id, :file, :_destroy]
    )
  end

  def crowd_campaign_comment_params
    params.require(:comment).permit(
      :content,
      images_attributes: [:file],
    )
  end

  def editable_campaign_params
    params
      .require(:crowd_campaign)
      .permit(
        :title, :slogan, :description, :support_description, :about_description, :benefit_description,
        :startdate, :enddate, :runtime, :billable, :benefit,
        :funding_1_amount, :funding_1_description, :funding_2_amount, :funding_2_description,
        :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
        :location_id, :room_offer_id,
        :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
        :cover_photo, :remove_cover_photo, :video, :avatar, :remove_avatar,
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

  def noneditable_campaign_params
    params.require(:crowd_campaign).permit(
      :description, :support_description, :about_description, :benefit_description,
      :location_id, :room_offer_id,
      images_attributes: [:id, :file, :_destroy],
      crowd_rewards_attributes: [
        :id, :amount, :limit, :title, :description, :delivery_weeks, :delivery_address_required, :question, :avatar, :remove_avatar, :_destroy
      ],
      crowd_donations_attributes: [
        :id, :donation_type, :limit, :title, :description, :question, :startdate, :enddate, :_destroy
      ],
    )
  end
end
