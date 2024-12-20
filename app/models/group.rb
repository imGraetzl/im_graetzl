class Group < ApplicationRecord
  include Trackable

  belongs_to :room_offer, optional: true
  belongs_to :room_demand, optional: true
  belongs_to :location, optional: true

  validates :title, presence: true
  validates :description, presence: true
  validates :cover_photo, presence: true
  validates :graetzl_ids, presence: true

  has_many :discussions, dependent: :destroy
  has_many :discussion_posts, through: :discussions

  has_many :group_users
  has_many :users, through: :group_users
  accepts_nested_attributes_for :group_users, allow_destroy: true, reject_if: :all_blank

  has_many :group_admins, -> { where(role: 'admin') }, class_name: "GroupUser", inverse_of: :group
  has_many :admins, through: :group_admins, source: :user

  has_many :group_members, -> { where(role: 'member') }, class_name: "GroupUser", inverse_of: :group
  has_many :members, through: :group_members, source: :user

  has_many :group_active_members, -> { where(role: 'member').where('last_activity_at IS NOT NULL') }, class_name: "GroupUser", inverse_of: :group
  has_many :active_members, through: :group_active_members, source: :user

  has_many :group_join_questions
  accepts_nested_attributes_for :group_join_questions, allow_destroy: true, reject_if: :all_blank
  has_many :group_join_requests, -> { includes(:user) }

  has_many :group_graetzls
  has_many :graetzls, through: :group_graetzls
  has_many :districts, -> { distinct }, through: :graetzls

  has_and_belongs_to_many :group_categories

  has_many :discussion_categories
  accepts_nested_attributes_for :discussion_categories, allow_destroy: true, reject_if: :all_blank

  include CoverImageUploader::Attachment(:cover_photo)

  scope :by_currentness, -> { order(featured: :desc, created_at: :desc) }
  scope :default_joined, -> { where(default_joined: true) }
  scope :non_private, -> { where(private: false) }
  scope :non_hidden, -> { where(hidden: false) }
  scope :featured, -> { where(featured: true) }

  def self.include_for_box
    includes(:group_categories, :admins)
  end

  def to_s
    title
  end

  def parent
    room_offer || room_demand || location
  end

  def last_active_members(size)
    user_ids = group_active_members.order("last_activity_at DESC").first(size).pluck(:user_id)
    User.registered.where(id: user_ids)
  end

  def admin?(user)
    cached_user_role(user) == "admin"
  end

  def member?(user)
    cached_user_role(user) == "member"
  end

  def in_group?(user)
    admin?(user) || member?(user)
  end

  def readable_by?(user)
    if private?
      in_group?(user)
    else
      true
    end
  end

  def postable_by?(user)
    in_group?(user)
  end

  def commentable_by?(user)
    in_group?(user)
  end

  def user_join_request(group_user)
    group_join_requests.find{|jr| jr.user_id == group_user.user_id }
  end

  private

  # Cached DB request to avoid loading all users in memory
  def cached_user_role(user)
    return 'none' if user.nil?
    @user_members ||= {}
    @user_members[user.id] ||= group_users.find_by(user_id: user.id)&.role || 'none'
  end
end
