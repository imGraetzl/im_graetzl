class ResetAllGroupUsersCacheCounters < ActiveRecord::Migration[5.2]
  def up

 Group.all.each do |group|

     Group.reset_counters(group.id, :group_users)

     end

  end

  def down

     # no rollback needed

  end
end
