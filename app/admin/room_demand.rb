ActiveAdmin.register RoomDemand do
  include ViewInApp
  menu priority: 8
  includes :location

  scope :all, default: true

  filter :graetzls
  filter :districts
  filter :daily_rent
  filter :longterm_rent
  filter :seeking_roommate
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

end
