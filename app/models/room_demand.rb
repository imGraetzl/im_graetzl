class RoomDemand < ApplicationRecord
  belongs_to :user

  has_many :room_demand_categories
  has_many :room_categories, through: :room_demand_categories

  has_many :room_demand_graetzls
  has_many :room_demand_districts
  has_many :graetzls, through: :room_demand_graetzls
  has_many :districts, through: :room_demand_districts

  acts_as_taggable_on :keywords

end
