class DiscussionPost < ApplicationRecord
  include Trackable

  belongs_to :user
  belongs_to :discussion
  has_one :group, through: :discussion

  has_many :images, as: :imageable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  after_create :set_discussion_last_post
  after_create :set_last_activity

  def deleted?
    user_id.blank?
  end

  def edit_permission?(by_user)
    by_user && user_id == by_user.id
  end

  def delete_permission?(by_user)
    return false if initial_post?
    by_user && (user_id == by_user.id || group.admins.include?(by_user))
  end

  def region_id
    group.region_id
  end

  private

  def set_discussion_last_post
    discussion.update(last_post_at: created_at)
  end

  def set_last_activity
    group.group_users.where(user_id: user.id).last.update(last_activity_at: Time.now)
  end

end
