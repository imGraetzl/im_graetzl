ActiveAdmin.register RoomOffer do
  include ViewInApp
  menu priority: 7
  includes :location

  scope :all, default: true
end
