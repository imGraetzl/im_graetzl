class LocationOwnership < ActiveRecord::Base
  # associations
  belongs_to :user
  belongs_to :location
end
