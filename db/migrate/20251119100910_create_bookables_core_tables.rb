class CreateBookablesCoreTables < ActiveRecord::Migration[7.2]
  def change
    create_table :bookables_cancellation_policies, if_not_exists: true do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.jsonb :rules, null: false, default: {}

      t.timestamps
    end
    add_index :bookables_cancellation_policies, :key, unique: true, if_not_exists: true

    create_table :bookables_availability_rules, if_not_exists: true do |t|
      t.references :bookable, polymorphic: true, null: false
      t.string :rrule, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end
    create_table :bookables_blackouts, if_not_exists: true do |t|
      t.references :bookable, polymorphic: true, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.string :reason

      t.timestamps
    end
    create_table :bookables_slot_policies, if_not_exists: true do |t|
      t.references :bookable,
                   polymorphic: true,
                   null: false,
                   index: { unique: true, name: "index_bookables_slot_policies_on_bookable" }
      t.integer :unit_minutes, null: false
      t.integer :min_units, null: false, default: 1
      t.integer :max_units, null: false, default: 1
      t.string :start_alignment, null: false, default: "on_hour"

      t.timestamps
    end
    create_table :bookables_price_rules, if_not_exists: true do |t|
      t.references :bookable, polymorphic: true, null: false
      t.string :strategy, null: false, default: "per_unit_rate"
      t.integer :unit_minutes
      t.decimal :amount, precision: 10, scale: 2
      t.integer :days_of_week, array: true, default: []
      t.time :time_from
      t.time :time_to
      t.date :date_from
      t.date :date_to
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end
  end
end
