class Post < ActiveRecord::Base

  # associations
  belongs_to :graetzl
  belongs_to :user
end
