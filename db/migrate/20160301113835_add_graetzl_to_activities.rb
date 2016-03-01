class AddGraetzlToActivities < ActiveRecord::Migration
  def up
    add_column :activities, :graetzl_id, :integer
    add_index :activities, :graetzl_id

    say_with_time 'Update graetzl_id for activities' do
      PublicActivity::Activity.find_each do |activity|
        activity.update graetzl_id: activity.trackable.graetzl_id
      end
    end
  end

  def down
    remove_index :activities, :graetzl_id
    remove_column :activities, :graetzl_id, :integer
  end
end
