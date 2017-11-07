class RoomDemand < ApplicationRecord
  belongs_to :user

  has_many :room_demand_categories
  has_many :room_categories, through: :room_demand_categories

  has_many :room_demand_graetzls
  has_many :graetzls, through: :room_demand_graetzls
  has_many :districts, through: :graetzls

  enum demand_type: { seeking_room: 0, seeking_roommate: 1 }
  acts_as_taggable_on :keywords

end
