class ApiAccount < ApplicationRecord

  scope :enabled, -> { where(enabled: true) }

  def full_access?
    name === 'imgraetzl'
  end

end
