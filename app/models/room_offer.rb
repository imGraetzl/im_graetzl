class RoomOffer < ApplicationRecord
  belongs_to :user
  belongs_to :graetzl
  belongs_to :district
  belongs_to :location, optional: true
  has_one :address, as: :addressable, dependent: :destroy

  has_many :room_offer_categories
  has_many :room_categories, through: :room_offer_categories

  acts_as_taggable_on :keywords

  attachment :main_image, type: :image
  has_many :images, as: :imageable, dependent: :destroy
  accepts_attachments_for :images, attachment: :file
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

end
