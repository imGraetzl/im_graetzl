class RoomSuggestedTag < ApplicationRecord

  def self.all_tags
    pluck(:name).map(&:downcase)
  end
end
