class RoomCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :room_offer_categories
  has_many :room_demand_categories

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  def to_s
    name
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

end
