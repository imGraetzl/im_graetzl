ActiveAdmin.register RoomOffer do
  include ViewInApp
  menu priority: 7
  includes :location

  scope :all, default: true

  filter :graetzl
  filter :district
  filter :daily_rent
  filter :longterm_rent
  filter :seeking_roommate
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

end
