class SquishUsernameUsers < ActiveRecord::Migration
  def up
    say_with_time 'Running pre validation callbacks on all users' do
      User.find_each(&:save)
    end
  end

  def down    
  end
end
