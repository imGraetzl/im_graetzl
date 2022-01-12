class RegionCall < ApplicationRecord

  enum region_type: { new_region: 0, existing_region: 1 }

  validates :region_id, presence: true, on: :create, if: :existing_region?
  validates :name, presence: true
  validates :phone, presence: true
  validates :gemeinden, presence: true
  validates :email, presence: true, format: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

end
