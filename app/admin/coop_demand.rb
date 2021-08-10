ActiveAdmin.register CoopDemand do
  include ViewInApp
  menu parent: 'Coop & Share'

  includes :location, :user, :comments
  actions :all, except: [:new, :create]

  scope :enabled, default: true
  scope :disabled
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user, collection: proc { User.admin_select_collection }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :coop_demand_categories
  filter :slogan
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :user_id, :slogan, :location_id, :demand_description,
    :personal_description, :slug, :avatar, :remove_avatar, :coop_demand_category_id,
    :first_name, :last_name, :website, :email, :phone, :status, graetzl_ids: [],
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
