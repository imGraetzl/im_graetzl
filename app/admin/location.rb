ActiveAdmin.register Location do
  include ViewInApp
  menu priority: 4
  includes :graetzl, :location_category, :users

  scope :all, default: true
  scope :pending
  scope :approved

  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :users, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location_category
  filter :state, as: :select, collection: Location.states.keys
  filter :name
  filter :slogan
  filter :description
  filter :allow_meetings
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # batch actions
  batch_action :approve do |ids|
    batch_action_collection.find(ids).map(&:approve)
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden freigeschalten.'
  end

  batch_action :reject, confirm: 'Wirklich alle ablehnen?' do |ids|
    batch_action_collection.find(ids).map(&:reject)
    redirect_to collection_path, alert: 'Die ausgewählten Locations wurden abgelehnt.'
  end

  # action buttons
  action_item :approve, only: :show, if: proc{ location.pending? } do
    link_to 'Location Freischalten', approve_admin_location_path(location), { method: :put }
  end

  action_item :reject, only: :show, if: proc{ location.pending? } do
    link_to 'Location Ablehnen', reject_admin_location_path(location), { method: :put }
  end

  # member actions
  member_action :approve, method: :put do
    if resource.approve
      flash[:success] = 'Location wurde freigeschalten.'
      redirect_to admin_locations_path
    else
      flash[:error] = 'Location kann nicht freigeschalten werden.'
      redirect_to resource_path
    end
  end

  member_action :reject, method: :put do
    if resource.reject
      flash[:notice] = 'Location wurde abgelehnt.'
      redirect_to admin_locations_path
    else
      flash[:error] = 'Location kann nicht abgelehnt werden.'
      redirect_to resource_path
    end
  end

  csv do
    column :id
    #column(:email) {|l| l.boss.email unless l.users.empty?}
    #column(:full_name) {|l| l.boss.full_name unless l.users.empty?}
    column(:location_category) {|l| l.location_category.name if l.location_category}
    column :name
    #column(:location_url) { |l| graetzl_location_url(l.graetzl, l)}
    #column :created_at
  end

  # strong parameters
  permit_params :graetzl_id,
    :state,
    :name,
    :slug,
    :slogan,
    :description,
    :allow_meetings,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    :location_category_id,
    :meeting_permission,
    :product_list,
    contact_attributes: [
      :id,
      :website,
      :email,
      :phone,
      :hours],
    address_attributes: [
      :id,
      :_destroy,
      :street_name,
      :street_number,
      :zip,
      :city,
      :coordinates,
      :description],
    location_ownerships_attributes: [
      :id,
      :user_id,
      :state,
      :_destroy],
    billing_address_attributes: [
      :id,
      :_destroy,
      :first_name,
      :last_name,
      :company,
      :street,
      :zip,
      :city,
      :country]
  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end
end
