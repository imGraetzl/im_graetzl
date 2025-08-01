ActiveAdmin.register Group do
  include ViewInApp
  menu parent: 'Einstellungen'

  actions :index, :show, :edit, :update, :destroy

  includes :graetzls, group_users: :user

  scope :all, default: true
  scope :featured

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :group_categories, input_html: { class: 'admin-filter-select'}
  filter :private, input_html: { class: 'admin-filter-select'}
  filter :title
  filter :created_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :title, :description, :featured, :hidden, :private, :room_offer_id, :room_demand_id,
    :location_id, :cover_photo, :remove_cover_photo, :default_joined, graetzl_ids: [],
    group_category_ids: [], group_users_attributes: [:id, :user_id, :role, :_destroy]
end
