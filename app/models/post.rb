class Post < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  # associations
  belongs_to :graetzl
  belongs_to :user

  # validations
  validates :content, presence: true
  validates :graetzl, presence: true
  validates :user, presence: true
end
