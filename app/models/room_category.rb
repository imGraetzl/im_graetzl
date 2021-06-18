class RoomCategory < ApplicationRecord
  has_many :room_offer_categories
  has_many :room_demand_categories

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  def to_s
    name
  end
end
