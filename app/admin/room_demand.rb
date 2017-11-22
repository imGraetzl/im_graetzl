ActiveAdmin.register RoomDemand do
  include ViewInApp
  menu parent: 'Rooms'
  includes :location
  actions :all, except: [:new, :create]

  scope :all, default: true

  filter :graetzls
  filter :districts
  filter :daily_rent
  filter :longterm_rent
  filter :demand_type
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

  form partial: 'form'

  permit_params :user_id, :slogan, :location_id, :needed_area, :daily_rent, :longterm_rent, :demand_description,
    :personal_description, :wants_collaboration, :demand_type, :slug,
    :avatar, :first_name, :last_name, :website, :email, :phone

end
