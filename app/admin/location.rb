ActiveAdmin.register Location do
  include ViewInApp
  menu priority: 4

  scope :all, default: true
  scope :pending
  scope :approved

  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]', scope: 'with_locations' }
  }
  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :districts, collection: proc { District.order(:zip).pluck(:zip, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :location_category, input_html: { class: 'admin-filter-select'}
  filter :verified, input_html: { class: 'admin-filter-select'}
  filter :state, as: :select, collection: Location.states.keys, input_html: { class: 'admin-filter-select'}
  filter :name
  filter :slogan
  filter :description
  filter :online_shop
  filter :allow_meetings
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # batch actions
  batch_action :approve do |ids|
    batch_action_collection.find(ids).map(&:approved!)
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

    if resource.approved!
      LocationMailer.location_approved(resource).deliver_now
      ActionProcessor.track(resource, :create)

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

  # strong parameters
  permit_params :graetzl_id,
    :state,
    :verified,
    :name,
    :slug,
    :slogan,
    :description,
    :description_background,
    :description_favorite_place,
    :allow_meetings,
    :avatar, :remove_avatar,
    :cover_photo, :remove_cover_photo,
    :location_category_id,
    :product_list,
    :website_url,
    :online_shop_url,
    :email,
    :phone,
    :open_hours,
    :goodie,
    :address_street,
    :address_zip,
    :address_city,
    :address_coordinates,
    :address_description,
    :user_id,
    images_attributes: [:id, :file, :_destroy]

  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do

    def scoped_collection
      super.includes(:graetzl, :location_category, :user)
    end

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
    column :state
    column(:l_graetzl) {|l| l.graetzl.name}
    column(:plz) { |l| l.graetzl.zip }
    column :region
    #column(:email) {|l| l.user.email if l.user}
    #column(:l_plz) {|l| l.address_zip}
    #column(:location_category) {|l| l.location_category.name if l.location_category}
    #column(:location_url) { |l| Rails.application.routes.url_helpers.graetzl_location_path(l.graetzl, l)}
    #column(:l_graetzl_url) { |l| Rails.application.routes.url_helpers.graetzl_path(l.graetzl)}
  end

end
