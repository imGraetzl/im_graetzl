class RemovePostActivity < ActiveRecord::Migration
  def up
    say_with_time 'Remove obsolete post type activity' do
      Activity.where(trackable_type: 'Post').destroy_all
    end
  end

  def down
    #nothing to do here
  end
end
