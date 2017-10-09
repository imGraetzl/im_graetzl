ActiveAdmin.register RoomOffer do
  menu parent: 'Rooms'
  includes :location

  scope :all, default: true

  filter :graetzl
  filter :district
  filter :daily_rent
  filter :offer_type
  filter :longterm_rent
  filter :wants_collaboration
  filter :created_at
  filter :updated_at

end
