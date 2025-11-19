class CreateAvailabilityTemplates < ActiveRecord::Migration[7.2]
  def change
    create_table :availability_templates, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :scope, null: false, default: 0
      t.boolean :respect_holidays, null: false, default: false
      t.string :holiday_region
      t.boolean :archived, null: false, default: false

      t.timestamps
    end
    add_index :availability_templates,
              %i[user_id name scope],
              unique: true,
              name: "index_availability_templates_on_user_name_scope",
              if_not_exists: true

    create_table :availability_template_rules, if_not_exists: true do |t|
      t.references :availability_template,
                   null: false,
                   foreign_key: true,
                   index: { name: "index_availability_template_rules_on_template" }
      t.string :rrule, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end
  end
end
