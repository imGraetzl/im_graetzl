class RemovePostNotifications < ActiveRecord::Migration
  def up
    say_with_time 'Remove obsolete post type notifications' do
      types = [
        'Notifications::AlsoCommentedPost',
        'Notifications::CommentOnLocationsPost',
        'Notifications::CommentOnUsersPost',
        'Notifications::NewLocationPost',
        'Notifications::NewUserPost']
      Notification.where(type: types).destroy_all
    end
  end

  def down
    #nothing to do here
  end
end
