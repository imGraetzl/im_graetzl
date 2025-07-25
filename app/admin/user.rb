ActiveAdmin.register User do
  include ViewInApp
  menu priority: 2
  includes :graetzl, :location_category, :business_interests

  scope :registered, default: true
  scope :guests
  scope :admins
  scope :beta
  scope :trusted
  Region.all.each do |region|
    scope(region.name) { |scope| scope.registered.where(region_id: region.id) }
  end

  filter :id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[id_eq]' }
  }
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select' }
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location_category, collection: proc { LocationCategory.pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :subscribed, label: 'Fördermitglied', input_html: { class: 'admin-filter-select'}
  filter :first_name
  filter :last_name
  filter :email
  filter :stripe_customer_id, label: 'Stripe ID'
  filter :stripe_connect_account_id, label: 'Stripe Connect ID'
  filter :created_at

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
    :trust_level,
    :business,
    :location_category,
    :business_interests,
    :address_street,
    :address_zip,
    :address_city,
    :address_coordinates,
    :address_description,
    :stripe_connect_account_id,
    :stripe_connect_ready,
    :free_region_zuckerl,
    :free_graetzl_zuckerl,
    group_ids: [],
    favorite_graetzl_ids: []

    # Within app/admin/resource_name.rb
    # Controller pagination overrides
    controller do
        def apply_pagination(chain)
            chain = super unless formats.include?(:json) || formats.include?(:csv)
            chain
        end
    end

    csv do
      column :id
      column :created_at
      column :email
      column :full_name
      column(:graetzl) { |user| user.graetzl }
      column(:plz) { |user| user.graetzl.zip }
      column :region_id
      #column :newsletter
    end
end
