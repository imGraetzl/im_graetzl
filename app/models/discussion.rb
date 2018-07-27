class Discussion < ApplicationRecord
  include Trackable

  belongs_to :group
  belongs_to :user
  belongs_to :group_category, optional: true

  has_many :discussion_posts
  has_many :discussion_followings
  has_many :following_users, through: :discussion_followings, source: :user

  scope :sticky, -> { where(sticky: true) }
  scope :regular, -> { where(sticky: false) }

  def open?
    !closed?
  end

  def delete_permission?(by_user)
    group.admins.include?(by_user)
  end

  def followed_by?(by_user)
    discussion_followings.where(user: by_user).exists?
  end

end
