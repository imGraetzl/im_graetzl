ActiveAdmin.register RoomOffer do
  include ViewInApp
  menu parent: 'Rooms'
  includes :graetzl, :location

  scope :all, default: true

  filter :graetzl
  filter :district
  filter :daily_rent
  filter :offer_type
  filter :longterm_rent
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

  permit_params :user_id, :slogan, :graetzl_id, :district_id, :location_id, :room_description, :total_area,
    :rented_area, :daily_rent, :longterm_rent, :owner_description, :tenant_description, :wants_collaboration,
    :slug, :offer_type,
    address_attributes: [ :id, :_destroy, :street_name, :street_number, :zip, :city, :coordinates, :description]


end
