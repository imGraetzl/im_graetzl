class OperatingRange < ApplicationRecord
  belongs_to :graetzl
  belongs_to :operator, polymorphic: true
end
