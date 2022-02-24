class CreateCrowdPledges < ActiveRecord::Migration[6.1]
  def change
    create_table :crowd_pledges do |t|

      t.integer "status", default: 0
      t.decimal "amount", precision: 10, scale: 2
      t.string "contact_name"
      t.string "address_street"
      t.string "address_zip"
      t.string "address_city"
      t.string "region_id"
      t.text "anwser"

      t.references :crowd_campaign, foreign_key: { on_delete: :nullify }, index: true
      t.references :crowd_reward, foreign_key: { on_delete: :nullify }, index: true
      t.references :user, foreign_key: { on_delete: :nullify }, index: true

      t.timestamps
    end

    create_table :crowd_donation_pledges do |t|

      t.integer "status", default: 0
      t.string "contact_name"
      t.string "region_id"
      t.text "anwser"

      t.references :crowd_campaign, foreign_key: { on_delete: :nullify }, index: true
      t.references :crowd_donation, foreign_key: { on_delete: :nullify }, index: true
      t.references :user, foreign_key: { on_delete: :nullify }, index: true

      t.timestamps
    end

    add_index :crowd_pledges, :region_id
    add_index :crowd_donation_pledges, :region_id

  end
end
