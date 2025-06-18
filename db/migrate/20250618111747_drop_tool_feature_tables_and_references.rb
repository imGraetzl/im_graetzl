class DropToolFeatureTablesAndReferences < ActiveRecord::Migration[6.1]
  def up
    # Foreign keys entfernen
    remove_foreign_key :tool_demand_graetzls, :tool_demands if foreign_key_exists?(:tool_demand_graetzls, :tool_demands)
    remove_foreign_key :tool_demand_graetzls, :graetzls if foreign_key_exists?(:tool_demand_graetzls, :graetzls)
    remove_foreign_key :tool_demands, :tool_categories if foreign_key_exists?(:tool_demands, :tool_categories)
    remove_foreign_key :tool_demands, :locations if foreign_key_exists?(:tool_demands, :locations)
    remove_foreign_key :tool_demands, :users if foreign_key_exists?(:tool_demands, :users)
    remove_foreign_key :tool_offers, :tool_categories if foreign_key_exists?(:tool_offers, :tool_categories)
    remove_foreign_key :tool_offers, :locations if foreign_key_exists?(:tool_offers, :locations)
    remove_foreign_key :tool_offers, :graetzls if foreign_key_exists?(:tool_offers, :graetzls)
    remove_foreign_key :tool_offers, :users if foreign_key_exists?(:tool_offers, :users)
    remove_foreign_key :tool_rentals, :tool_offers if foreign_key_exists?(:tool_rentals, :tool_offers)
    remove_foreign_key :tool_rentals, :users if foreign_key_exists?(:tool_rentals, :users)
    remove_foreign_key :user_message_threads, :tool_rentals if foreign_key_exists?(:user_message_threads, :tool_rentals)

    # Spalte in anderer Tabelle entfernen
    if column_exists?(:user_message_threads, :tool_rental_id)
      remove_index :user_message_threads, :tool_rental_id if index_exists?(:user_message_threads, :tool_rental_id)
      remove_column :user_message_threads, :tool_rental_id
    end

    # Tabellen entfernen (löscht automatisch auch zugehörige Indizes)
    drop_table :tool_demand_graetzls if table_exists?(:tool_demand_graetzls)
    drop_table :tool_rentals if table_exists?(:tool_rentals)
    drop_table :tool_offers if table_exists?(:tool_offers)
    drop_table :tool_demands if table_exists?(:tool_demands)
    drop_table :tool_categories if table_exists?(:tool_categories)
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Tool-Feature-Tabellen und Referenzen wurden gelöscht."
  end
end
