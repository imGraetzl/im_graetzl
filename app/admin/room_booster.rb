ActiveAdmin.register RoomBooster do
  menu parent: 'Raumteiler'
  includes :room_offer, :user
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :initialized, default: true
  scope :active
  scope :upcoming
  scope :expired
  scope :storno
  scope :incomplete
  scope :free
  scope :all

  index { render 'index', context: self }
end
