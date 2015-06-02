class Comment < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # associations
  belongs_to :user
  belongs_to :commentable, polymorphic: true
end
