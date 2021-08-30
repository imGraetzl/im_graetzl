class CoopSuggestedTag < ApplicationRecord

  belongs_to :coop_demand_category, optional: true

  def self.all_tags
    pluck(:name).map(&:downcase)
  end
end
