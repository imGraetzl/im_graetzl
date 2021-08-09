class ChangeRoomSuggestedTagsToCoopSuggestedTags < ActiveRecord::Migration[6.1]
  def change
    rename_table :room_suggested_tags, :coop_suggested_tags
  end
end
