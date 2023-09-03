ActiveAdmin.register CrowdCampaign do
  include ViewInApp
  menu parent: 'Crowdfunding'

  includes :location, :user, :comments
  actions :all, except: [:new, :create]

  scope :all, default: true
  scope :draft
  scope :pending
  scope :declined
  scope :approved
  scope :funding
  scope :completed
  scope 'Visible', :scope_public
  scope 'Throttled',  :scope_throttled

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_categories
  filter :visibility_status
  filter :title
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # action buttons
  action_item :approve, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Kampagne freischalten', approve_admin_crowd_campaign_path(crowd_campaign), { method: :put }
  end

  action_item :decline, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Kampagne ablehnen', decline_admin_crowd_campaign_path(crowd_campaign), { method: :put }
  end

  action_item :draft, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Kampagne zurück auf Draft setzen', draft_admin_crowd_campaign_path(crowd_campaign), { method: :put }
  end

  # member actions
  member_action :approve, method: :put do
    if resource.approved!
      CrowdCampaignMailer.approved(resource).deliver_now
      flash[:success] = 'Crowdfunding Kampagne wurde freigeschalten.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht freigeschalten werden.'
      redirect_to resource_path
    end
  end

  member_action :decline, method: :put do
    if resource.declined!
      flash[:success] = 'Crowdfunding Kampagne wurde abgelenht.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht abgelenht werden.'
      redirect_to resource_path
    end
  end

  member_action :draft, method: :put do
    if resource.draft!
      flash[:success] = 'Crowdfunding Kampagne wurde zurückgesetzt auf Draft.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht auf Draft zurückgesetzt werden'
      redirect_to resource_path
    end
  end

  permit_params :active_state, :visibility_status, :status, :title, :slogan, :description, :support_description, :aim_description, :about_description, :benefit, :benefit_description,
    :startdate, :enddate, :billable, :service_fee_percentage,
    :funding_1_amount, :funding_1_description, :funding_2_amount, :funding_2_description,
    :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
    :location_id, :room_offer_id, :user_id,
    :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
    :cover_photo, :remove_cover_photo, :video, :avatar, :remove_avatar,
    crowd_category_ids: [],
    images_attributes: [:id, :file, :_destroy],
    crowd_rewards_attributes: [:id, :title, :description, :question, :limit],
    crowd_donations_attributes: [:id, :title, :description, :question]

  # Within app/admin/resource_name.rb
  # Controller pagination overrides

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

end
