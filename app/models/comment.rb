class Comment < ApplicationRecord
  include Trackable

  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :images, as: :imageable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  validates :content, presence: true

  after_create :set_last_activity

  def self.include_for_box
    preload(:user, :commentable)
  end

  def edit_permission?(by_user)
    by_user && (by_user.admin? || user_id == by_user.id || commentable == by_user)
  end

  def preview
    content.truncate(300, separator: ' ')
  end

  def region_id
    commentable.region_id
  end

  def target_url_params
    "comment_#{commentable.class.name.underscore}_#{id}"
  end

  private

  def set_last_activity
    if commentable_type == "DiscussionPost"
      group = DiscussionPost.where(id: commentable_id).last.discussion.group
      group.group_users.where(user_id: user.id).last.update(last_activity_at: Time.now)
    end
  end

end
