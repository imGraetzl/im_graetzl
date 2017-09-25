class RoomDemandCategory < ApplicationRecord
  belongs_to :room_demand
  belongs_to :room_category
end
