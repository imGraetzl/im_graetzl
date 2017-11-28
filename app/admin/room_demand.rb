ActiveAdmin.register RoomDemand do
  include ViewInApp
  menu parent: 'Rooms'
  includes :location, :user, :comments
  actions :all, except: [:new, :create]

  scope :all, default: true

  filter :graetzls
  filter :districts
  filter :demand_type
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

  index { render 'index', context: self }
  show { render 'show', context: self }
  form partial: 'form'

  permit_params :user_id, :slogan, :location_id, :needed_area, :demand_description,
    :personal_description, :wants_collaboration, :demand_type, :slug, :avatar, :remove_avatar,
    :first_name, :last_name, :website, :email, :phone,
    room_category_ids: []

end
