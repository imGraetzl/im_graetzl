class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  has_one :contact, dependent: :destroy
  has_many :location_ownerships, dependent: :destroy
  has_many :users, through: :location_ownerships
end
