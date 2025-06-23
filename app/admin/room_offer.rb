ActiveAdmin.register RoomOffer do
  include ViewInApp
  menu parent: 'Raumteiler'
  includes :graetzl, :location, :user, :comments
  actions :all, except: [:new, :create]

  scope :enabled, default: true
  scope :rentable
  scope :boosted
  scope :disabled
  scope :occupied
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :room_categories
  filter :rental_enabled
  filter :slogan
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :user_id, :slogan, :graetzl_id, :district_id, :location_id, :room_description, :total_area,
    :rented_area, :owner_description, :tenant_description, :wants_collaboration, :keyword_list,
    :slug, :offer_type, :cover_photo, :remove_cover_photo, :avatar, :remove_avatar,
    :first_name, :last_name, :website, :email, :phone, :status,
    :address_street,
    :address_zip,
    :address_city,
    :address_coordinates,
    :address_description,
    room_offer_price_ids: [],
    room_category_ids: [],
    room_offer_prices_attributes: [ :id, :name, :amount, :_destroy],
    images_attributes: [:id, :file, :_destroy]
  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
    def apply_filtering(chain)
        super(chain).distinct
    end
  end

  csv do
    column :id
    column :created_at
    column :status
    column :region_id
    column(:plz) { |room| room.graetzl.zip }
    column(:graetzl) { |room| room.graetzl }
    column(:room_type) { |room| I18n.t("activerecord.attributes.room_offer.offer_types.#{room.offer_type}")}
    column(:category)  { |room| room.room_categories.map(&:name).join(", ") }
    column :slogan
    column(:room_url) { |room| Rails.application.routes.url_helpers.room_offer_url(room, host: room.region.host)}
    column(:keywords)  { |room| room.keywords.map(&:name).join(", ") }
    column :total_area
    column :rented_area
    column :wants_collaboration
    column :rental_enabled
    column :address_street
    column :address_zip
    column :address_city
    column :address_coordinates
    column :updated_at
    column :last_activated_at
    column :room_description
    column :owner_description
    column :tenant_description
  end

end
