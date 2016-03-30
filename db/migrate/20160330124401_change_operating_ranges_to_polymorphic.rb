class ChangeOperatingRangesToPolymorphic < ActiveRecord::Migration
  def up
    remove_index :operating_ranges, column: :initiative_id
    change_table :operating_ranges do |t|
      t.rename :initiative_id, :operator_id
      t.string :operator_type
    end
    add_index :operating_ranges, [:operator_id, :operator_type]
    say_with_time 'Migrate initiave operating-ranges to polymorphic' do
      OperatingRange.update_all(operator_type: 'Initiative')
    end
  end

  def down
    say_with_time 'Remove AdminPosts' do
      AdminPost.destroy_all
    end
    remove_index :operating_ranges, column: [:operator_id, :operator_type]
    change_table :operating_ranges do |t|
      t.rename :operator_id, :initiative_id
      t.remove :operator_type
    end
    add_index :operating_ranges, :initiative_id
  end
end
