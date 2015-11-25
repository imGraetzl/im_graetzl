ActiveAdmin.register Meeting do
  include ViewInApp
  menu priority: 5

  scope :all, default: true
  scope :basic
  scope :cancelled
  scope :upcoming
  scope :past

  # index
  index do
    render 'index', context: self
  end

  # filter
  filter :graetzl
  filter :users
  filter :location
  filter :name
  filter :description
  filter :state, as: :select, collection: Meeting.states.keys
  filter :created_at
  filter :updated_at
  filter :starts_at_date
  filter :ends_at_date

  # show
  show do
    render 'show', context: self
  end

  # form
  form partial: 'form'

  # strong parameters
  permit_params :graetzl_id,
    :name,
    :slug,
    :state,
    :description,
    :cover_photo, :remove_cover_photo,
    :starts_at_date, :starts_at_time,
    :ends_at_date, :ends_at_time,
    :location_id,
    address_attributes: [
      :id,
      :street_name,
      :street_number,
      :zip,
      :city,
      :coordinates,
      :description],
    going_tos_attributes: [
      :id,
      :user_id,
      :role,
      :_destroy]
end
