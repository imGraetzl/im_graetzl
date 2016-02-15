class LocationOwnership < ActiveRecord::Base

  belongs_to :user
  belongs_to :location

  enum state: { basic: 0, pending: 1 }
end
