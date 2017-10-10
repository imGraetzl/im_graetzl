ActiveAdmin.register RoomDemand do
  menu parent: 'Rooms'
  includes :location

  scope :all, default: true

  filter :graetzls
  filter :districts
  filter :daily_rent
  filter :longterm_rent
  filter :demand_type
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

  permit_params :user_id, :slogan, :needed_area, :daily_rent, :longterm_rent, :demand_description,
    :personal_description, :wants_collaboration, :demand_type, :slug

end
