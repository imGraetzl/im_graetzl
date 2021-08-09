class AddCoopDemandCategoryToCoopSuggestedTags < ActiveRecord::Migration[6.1]
  def change
    add_reference :coop_suggested_tags, :coop_demand_category
    add_foreign_key :coop_suggested_tags, :coop_demand_categories, on_delete: :nullify
  end
end
