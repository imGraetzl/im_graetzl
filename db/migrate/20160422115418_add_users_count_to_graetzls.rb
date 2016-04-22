class AddUsersCountToGraetzls < ActiveRecord::Migration
  def up
    add_column :graetzls, :users_count, :integer, default: 0
    say_with_time 'Update counter cache value for existing records' do
      Graetzl.find_each { |g| Graetzl.reset_counters(g.id, :users) }
    end
  end
  def down
    remove_column :graetzls, :users_count, :integer
  end
end
