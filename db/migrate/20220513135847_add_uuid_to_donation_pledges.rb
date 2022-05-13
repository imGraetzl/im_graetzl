class AddUuidToDonationPledges < ActiveRecord::Migration[6.1]
  def change
    add_column :crowd_donation_pledges, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :crowd_donation_pledges do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE crowd_donation_pledges ADD PRIMARY KEY (id);"
  end
end
