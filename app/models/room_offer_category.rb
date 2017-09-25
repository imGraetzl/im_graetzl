class RoomOfferCategory < ApplicationRecord
  belongs_to :room_offer
  belongs_to :room_category
end
