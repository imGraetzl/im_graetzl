class AddCrowdCampaignPosts < ActiveRecord::Migration[6.1]
  def change
    create_table :crowd_campaign_posts do |t|
      t.string "title"
      t.text "content"
      t.string "region_id"

      t.timestamps

      t.references :crowd_campaign, foreign_key: { on_delete: :cascade }, index: true
      t.references :graetzl, foreign_key: { on_delete: :nullify }, index: true

    end

    add_index :crowd_campaign_posts, :region_id

  end
end
