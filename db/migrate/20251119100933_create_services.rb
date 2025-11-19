class CreateServices < ActiveRecord::Migration[7.2]
  def change
    create_table :services, if_not_exists: true do |t|
      t.references :location, null: false, foreign_key: true
      t.references :location_category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :owner, null: true, foreign_key: { to_table: :users }
      t.references :availability_template, null: false, foreign_key: true
      t.references :cancellation_policy,
                   null: true,
                   foreign_key: { to_table: :bookables_cancellation_policies }
      t.string :title, null: false
      t.string :summary, null: false, limit: 280
      t.text :description, null: false
      t.jsonb :cover_photo_data, null: false, default: {}
      t.string :slug, null: false
      t.string :region_id, null: false
      t.decimal :price_amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :services, :slug, unique: true, if_not_exists: true
    add_index :services, :region_id, if_not_exists: true

    create_table :service_resources_services, if_not_exists: true do |t|
      t.references :service_resource, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
    add_index :service_resources_services,
              %i[service_resource_id service_id],
              unique: true,
              name: "index_service_resources_services_on_resource_service",
              if_not_exists: true
  end
end
