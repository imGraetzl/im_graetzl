class ApiAccount < ApplicationRecord

  scope :enabled, -> { where(enabled: true) }
end
