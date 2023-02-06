class RegionCall < ApplicationRecord

  enum region_type: { new_region: 0, existing_region: 1 }

  validates :gemeinden, presence: true
  validates :name, presence: true
  validates :email, presence: true, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :phone, presence: true

end
