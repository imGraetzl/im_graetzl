class ChangeUserToAuthorPosts < ActiveRecord::Migration
  def up
    Post.find_each do |post|
      post.update(author_id: post.user_id, author_type: 'User')
    end
  end

  def down
    # nothing to do here, user_id column still present
  end
end
