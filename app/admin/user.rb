ActiveAdmin.register User do
  include ViewInApp
  menu priority: 3
  includes :graetzl, :location_category, :business_interests

  scope :all, default: true
  scope :business
  scope :admin

  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select' }
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :id, label: 'User', as: :select, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location_category, collection: proc { LocationCategory.pluck(:name, :id) }, include_blank: true
  filter :business_interests, collection: proc { BusinessInterest.pluck(:title, :id) }, include_blank: true
  filter :first_name
  filter :last_name
  filter :email
  filter :origin
  filter :created_at
  filter :last_sign_in_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :graetzl_id,
    :username,
    :first_name,
    :last_name,
    :email,
    :password,
    :newsletter,
    :bio,
    :website,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    :role,
    :business,
    :location_category,
    :business_interests,
    group_ids: [],
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :description,
      :coordinates]

    # Within app/admin/resource_name.rb
    # Controller pagination overrides
    controller do
        def apply_pagination(chain)
            chain = super unless formats.include?(:json) || formats.include?(:csv)
            chain
        end
    end

    csv do
      #column :id
      column :email
      #column :username
      #column :first_name
      #column :last_name
      #column :newsletter
      #column :created_at
      #column(:business) {|user| user.business? ? 'business' : '' }
      column(:plz) { |user| user.graetzl.districts.first.try(:zip) }
      column(:graetzl) { |user| user.graetzl.name }
      #column(:graetzl_url) { |user| Rails.application.routes.url_helpers.graetzl_path(user.graetzl) }
      #column(:profil_url) { |user| Rails.application.routes.url_helpers.user_path(user) }
      #column :origin
      #column(:location_category) {|user| user.location_category.try(:name) }
    end
end
