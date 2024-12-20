ActiveAdmin.register ToolOffer do
  include ViewInApp
  menu parent: 'Geräteteiler'
  includes :graetzl, :location, :user, :comments
  actions :all, except: [:new, :create, :destroy]

  scope :enabled, default: true
  scope :all
  scope :disabled
  scope :deleted

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.registered.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :tool_categories
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :title, :description, :brand, :model, :status, :keyword_list,
    :value_up_to, :serial_number, :known_defects, :deposit,
    :price_per_day, :two_day_discount, :weekly_discount,
    :tool_category_id, :location_id,
    :cover_photo, :remove_cover_photo,
    :first_name, :last_name, :iban,
    :address_street,
    :address_zip,
    :address_city,
    :address_coordinates,
    :address_description,
    images_attributes: [:id, :file, :_destroy]

  controller do
    def apply_pagination(chain)
      chain = super unless formats.include?(:json) || formats.include?(:csv)
      chain
    end
  end
end
