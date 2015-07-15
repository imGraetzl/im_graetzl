class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
  attachment :avatar, type: :image
  attachment :cover_photo, type: :image

  # associations
  belongs_to :graetzl
  has_one :address, as: :addressable, dependent: :destroy
  accepts_nested_attributes_for :address
  has_one :contact, dependent: :destroy
  accepts_nested_attributes_for :contact
  has_many :location_ownerships, dependent: :destroy
  has_many :users, through: :location_ownerships

  # validations
  validates :name, presence: true
end
