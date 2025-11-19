class CreateServiceResourcesAndBlackouts < ActiveRecord::Migration[7.2]
  def change
    create_table :service_resources, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :bio
      t.references :avatar, type: :integer, foreign_key: { to_table: :images }

      t.timestamps
    end

    create_table :bookables_provider_blackouts, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :reason

      t.timestamps
    end
    add_index :bookables_provider_blackouts,
              %i[user_id starts_at],
              name: "index_bookables_provider_blackouts_on_user_and_start",
              if_not_exists: true

    create_table :bookables_resource_blackouts, if_not_exists: true do |t|
      t.references :service_resource, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :reason

      t.timestamps
    end
    add_index :bookables_resource_blackouts,
              %i[service_resource_id starts_at],
              name: "index_bookables_resource_blackouts_on_resource_and_start",
              if_not_exists: true
  end
end
