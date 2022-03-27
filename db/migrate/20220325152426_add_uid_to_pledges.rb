class AddUidToPledges < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto'
    add_column :crowd_pledges, :uuid, :uuid, default: "gen_random_uuid()", null: false

    change_table :crowd_pledges do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute "ALTER TABLE crowd_pledges ADD PRIMARY KEY (id);"
  end
end
