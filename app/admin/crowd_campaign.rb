ActiveAdmin.register CrowdCampaign do
  include ViewInApp
  menu parent: 'Crowdfunding'

  includes :location, :user, :comments
  actions :all, except: [:new, :create]

  scope :all, default: true
  scope :draft
  scope :pending
  scope :approved

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :crowd_categories
  filter :title
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # batch actions
  #batch_action :approve do |ids|
  #  batch_action_collection.find(ids).map(&:approved!)
  #  redirect_to collection_path, alert: 'Die ausgewählten Crowdfunding Kampagnen wurden freigeschalten.'
  #end

  # action buttons
  action_item :approve, only: :show, if: proc{ crowd_campaign.pending? } do
    link_to 'Kampagne Freischalten', approve_admin_crowd_campaign_path(crowd_campaign), { method: :put }
  end

  # member actions
  member_action :approve, method: :put do

    if resource.approved!
      #UsersMailer.crowd_campaign_approved(resource).deliver_now
      ActionProcessor.track(resource, :create) # Move to Background Task (State Funding)

      flash[:success] = 'Crowdfunding Kampagne wurde freigeschalten.'
      redirect_to admin_crowd_campaigns_path
    else
      flash[:error] = 'Crowdfunding Kampagne kann nicht freigeschalten werden.'
      redirect_to resource_path
    end
  end

  permit_params :status, :title, :slogan, :description, :support_description, :about_description,
    :startdate, :runtime, :billable,
    :funding_1_amount, :funding_1_description, :funding_2_amount, :funding_2_description,
    :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
    :location_id, :room_offer_id,
    :graetzl_id, :address_street, :address_coords, :address_city, :address_zip, :address_description,
    :cover_photo, :remove_cover_photo, :video,
    crowd_category_ids: [],
    images_attributes: [:id, :file, :_destroy]

  # Within app/admin/resource_name.rb
  # Controller pagination overrides

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end

end
