class LocationCategory < ApplicationRecord
  enum context: { recreation: 0, business: 1 }
  has_many :locations

  attachment :main_photo, type: :image

end
