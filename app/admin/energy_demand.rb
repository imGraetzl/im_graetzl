ActiveAdmin.register EnergyDemand do
  include ViewInApp
  menu parent: 'Energieteiler'
  includes :user, :comments
  actions :all, except: [:new, :create]

  scope :enabled, default: true
  scope :disabled
  scope :all

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzls, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :energy_categories, input_html: { class: 'admin-filter-select'}
  filter :title
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }

  permit_params :energy_type,
    :organization_form,
    :orientation_type,
    :title,
    :description,
    :goal_producer_solarpower,
    :goal_prosumer_solarpower,
    :goal_producer_hydropower,
    :goal_prosumer_hydropower,
    :goal_producer_windpower,
    :goal_prosumer_windpower,
    :goal_roofspace,
    :goal_freespace,
    :avatar,
    :activation_code,
    :remove_avatar,
    :last_activated_at,
    :graetzl_id,
    :address_street, :address_coords, :address_city, :address_zip, :address_description,
    :contact_company, :contact_name, :contact_address, :contact_zip, :contact_city, :contact_website, :contact_email, :contact_phone,
    energy_category_ids: [],
    graetzl_ids: []

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

end
