class RoomCategory < ApplicationRecord
  has_many :room_offer_categories
  has_many :room_demand_categories

end
