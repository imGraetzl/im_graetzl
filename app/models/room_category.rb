class RoomCategory < ApplicationRecord
  has_many :room_offer_categories
  has_many :room_demand_categories

  include ImageUploader::Attachment(:main_photo)

  def to_s
    name
  end
end
