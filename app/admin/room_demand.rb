ActiveAdmin.register RoomDemand do
  include ViewInApp
  menu parent: 'Raumteiler'
  includes :location, :user, :comments
  actions :all, except: [:new, :create]

  scope :enabled, default: true
  scope :disabled
  scope :all

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]', scope: 'with_room_demands' }
  }
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :room_categories, input_html: { class: 'admin-filter-select'}
  filter :slogan
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :user_id, :entire_region, :slogan, :location_id, :needed_area, :demand_description,
    :personal_description, :wants_collaboration, :demand_type, :slug, :avatar, :remove_avatar,
    :first_name, :last_name, :website, :email, :phone, :status, graetzl_ids: [],
    room_category_ids: []
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
    #column(:email) {|room| room.user.email if room.user }
    #column :slogan
    #District.all.order(:zip).each do |district|
    #  column("#{district.zip}") {|room| district.room_demands.find_by_id(room.id) ? (1 / room.districts.count.to_f).round(3) : 0}
    #end
    #RoomCategory.all.sort_by(&:position).each do |category|
    #  column("#{category.name}") {|room| category.room_demands.find_by_id(room.id) ? (1 / room.room_categories.count.to_f).round(3) : 0}
    #end
    #column :created_at
    #column(:room_url) { |room| Rails.application.routes.url_helpers.room_demand_path(room)}
    #column(:room_state) { |room| I18n.t("activerecord.attributes.room_demand.statuses.#{room.status}")}
    #column(:room_type) { |room| I18n.t("activerecord.attributes.room_demand.demand_types.#{room.demand_type}")}
  end

end
