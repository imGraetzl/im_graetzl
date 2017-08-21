ActiveAdmin.register Meeting do
  include ViewInApp
  menu priority: 6
  includes :graetzl, :location

  scope :all, default: true
  scope :basic
  scope :cancelled
  scope :upcoming

  filter :graetzl
  filter :users
  filter :location
  filter :name
  filter :description
  filter :state, as: :select, collection: Meeting.states.keys
  filter :created_at
  filter :starts_at_date

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :graetzl_id,
    :name,
    :slug,
    :state,
    :description,
    :cover_photo, :remove_cover_photo,
    :starts_at_date, :starts_at_time,
    :ends_at_time,
    :location_id,
    :approved_for_api,
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
