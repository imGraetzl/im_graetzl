class CreateUserGraetzls < ActiveRecord::Migration[6.1]
  def change
    create_table :user_graetzls do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }
      t.references :graetzl, index: true, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    create_table :activity_graetzls do |t|
      t.references :activity, index: true, foreign_key: { on_delete: :cascade }
      t.references :graetzl, index: true, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    rename_column :activities, :trackable_type, :subject_type
    rename_column :activities, :trackable_id, :subject_id
    rename_column :activities, :recipient_type, :child_type
    rename_column :activities, :recipient_id, :child_id
    rename_column :activities, :cross_platform, :entire_region
    remove_column :activities, :parameters, :text
    add_reference :activities, :group, index: true, foreign_key: { on_delete: :cascade }

    add_column :activities, :region_id, :string
    add_index :activities, :region_id

    add_column :notifications, :subject_type, :string
    add_column :notifications, :subject_id, :integer
    add_column :notifications, :child_type, :string
    add_column :notifications, :child_id, :integer

    add_index :notifications, [:subject_type, :subject_id]
    add_index :notifications, [:child_type, :child_id]

    add_column :notifications, :region_id, :string
    add_index :notifications, :region_id
  end
end