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
  filter :district, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
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
    column(:email) {|room| room.user.email if room.user }
    #column :slogan
    #column(:category)  { |room| room.room_categories.map(&:name).join(", ") }
    #column :created_at
    column(:room_url) { |room| Rails.application.routes.url_helpers.room_offer_path(room)}
    #column(:room_state) { |room| I18n.t("activerecord.attributes.room_offer.statuses.#{room.status}")}
    #column(:room_type) { |room| I18n.t("activerecord.attributes.room_offer.offer_types.#{room.offer_type}")}
  end

end
