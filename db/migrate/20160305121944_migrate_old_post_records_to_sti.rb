class MigrateOldPostRecordsToSti < ActiveRecord::Migration
  def up
    say_with_time 'Migrate Location Posts' do
      Post.where(author_type: 'Location').update_all(type: 'LocationPost')
    end
    say_with_time 'Remove User Posts' do
      Post.where(author_type: 'User').destroy_all
    end
    say_with_time 'Update slugs for remaining Posts' do
      Post.find_each(&:save)
    end
    say_with_time 'Update activities for remaining Posts' do
      Activity.where(key: 'post.create').update_all(key: 'location_post.create')
    end
  end

  def down
    # nothing to do here
  end
end
