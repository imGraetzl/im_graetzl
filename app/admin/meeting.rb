ActiveAdmin.register Meeting do
  include ViewInApp
  menu parent: 'Meetings'
  menu label: 'Treffen'
  menu priority: 5

  scope :all, default: true
  scope :upcoming

  filter :region_id, label: 'Region', as: :select, collection: proc { Region.all }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :event_categories, input_html: { class: 'admin-filter-select'}
  filter :graetzl, collection: proc { Graetzl.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :user_id_eq, label: "User Suche", as: :string, input_html: {
    class: 'admin-autocomplete-component',
    placeholder: 'Name, Username oder E-Mail ...',
    data: { autocomplete_url: '/admin/autocomplete/users', target_input: 'q[user_id_eq]' }
  }
  filter :location, collection: proc { Location.order(:name).pluck(:name, :id) }, include_blank: true, input_html: { class: 'admin-filter-select'}
  filter :name
  filter :description
  filter :created_at
  filter :online_meeting, input_html: { class: 'admin-filter-select'}
  filter :entire_region, input_html: { class: 'admin-filter-select'}

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  # batch actions
  batch_action :approve_for_api do |ids|
    batch_action_collection.where(id: ids).update_all(approved_for_api: true)
    redirect_to collection_path, alert: 'Die gewählten Treffen wurden für die API genehmigt.'
  end

  batch_action :disapprove_for_api, confirm: 'Wirklich aus API entfernen?' do |ids|
    batch_action_collection.where(id: ids).update_all(approved_for_api: false)
    redirect_to collection_path, alert: 'Die gewählten Treffen werden für die API nicht mehr genehmigt.'
  end

  # action buttons
  action_item :approve_for_api, only: :show, if: proc{ !meeting.approved_for_api? } do
    link_to 'API genehmigen', approve_for_api_admin_meeting_path(meeting), { method: :put }
  end

  action_item :disapprove_for_api, only: :show, if: proc{ meeting.approved_for_api? } do
    link_to 'API entfernen', disapprove_for_api_admin_meeting_path(meeting), { method: :put }
  end

  member_action :approve_for_api, method: :put do
    if resource.update(approved_for_api: true)
      flash[:success] = 'Das Treffen wurde für die API genehmigt.'
      redirect_to admin_meetings_path
    else
      flash[:error] = 'Das Treffen kann für die API nicht genehmigt werden.'
      redirect_to resource_path
    end
  end

  member_action :disapprove_for_api, method: :put do
    if resource.update(approved_for_api: false)
      flash[:notice] = 'Das Treffen ist nicht mehr für die API genehmigt.'
      redirect_to admin_meetings_path
    else
      flash[:error] = 'Das Treffen kann nicht für die API abgelehnt werden.'
      redirect_to resource_path
    end
  end

  # Within app/admin/resource_name.rb
  # Controller pagination overrides
  controller do

      def scoped_collection
        super.includes(:graetzl, :user, :location)
      end

      def apply_pagination(chain)
          chain = super unless formats.include?(:json) || formats.include?(:csv)
          chain
      end
      def apply_filtering(chain)
        super(chain).distinct
      end

      def update

        starts_at_date_before = resource.starts_at_date
        starts_at_time_before = resource.starts_at_time

        super

        if starts_at_date_before >= Date.today && (starts_at_date_before != resource.starts_at_date || starts_at_time_before != resource.starts_at_time)
          
          # Update Notifications and GoingTo Dates if Start Date is in future and changes

          ActionProcessor.track(resource, :update)
          resource.going_tos.where(going_to_date: starts_at_date_before, going_to_time: starts_at_time_before).update_all(
            going_to_date: resource.starts_at_date,
            going_to_time: resource.starts_at_time
          )

        end
        
      end
  end

  csv do
    column :id
    column :created_at
    column :starts_at_date
    column :graetzl
    column(:plz) { |m| m.graetzl.zip }
    column :region_id
    column(:email) {|m| m.user.email }
    column(:full_name) {|m| m.user.full_name }
    column :user_id
    column :name
    column(:going_tos) {|m| m.going_tos.count }
    column(:meeting_url) { |m| graetzl_meeting_url(m.graetzl, m)}
  end

  permit_params :graetzl_id,
    :name,
    :entire_region,
    :slug,
    :state,
    :max_going_tos,
    :description,
    :cover_photo, :remove_cover_photo,
    :starts_at_date, :starts_at_time,
    :ends_at_date, :ends_at_time,
    :location_id,
    :user_id,
    :approved_for_api,
    :online_meeting,
    :online_description,
    :address_street,
    :address_zip,
    :address_city,
    :address_coordinates,
    :address_description,
    images_attributes: [:id, :file, :_destroy],
    event_category_ids: [],
    meeting_additional_dates_attributes: [
      :id, :starts_at_date, :starts_at_time, :ends_at_time, :_destroy
    ],
    going_tos_attributes: [
      :id,
      :user_id,
      :role,
      :meeting_additional_date_id,
      :_destroy]
end
