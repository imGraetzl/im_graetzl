ActiveAdmin.register RoomDemand do
  include ViewInApp
  menu priority: 8
  includes :location

  scope :all, default: true
end
