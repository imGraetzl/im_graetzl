class Space < ApplicationRecord
  belongs_to :location
end

# TODO:
# - address
# - categories (can add them)
# - tags
# - photos (arbitrary number, max. file size)
# - SpaceOwnerships
