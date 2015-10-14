class Graetzl < ActiveRecord::Base
  extend FriendlyId

  # macros
  friendly_id :name
  enum state: { open: 0, closed: 1 }
  STREAM_ACTIVITY_KEYS = [
    'meeting.comment', 'meeting.create', 'meeting.go_to',
    'post.comment', 'post.create'
  ]

  # associations
  has_many :users
  has_many :meetings, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :locations, dependent: :destroy

  # instance methods
  def districts
    District.where('ST_INTERSECTS(area, :graetzl)', graetzl: self.area)
  end

  def district
    districts.first
  end

  # def activity_old
  #   a = PublicActivity::Activity.arel_table
  #   PublicActivity::Activity
  #     .select('DISTINCT ON(trackable_id, trackable_type) *')
  #     .where(a[:key].in(STREAM_ACTIVITY_KEYS))
  #     .where(
  #       a[:owner_id].in(users.pluck(:id)).or(
  #         a[:trackable_id].in(meetings.pluck(:id)).and(a[:trackable_type].eq('Meeting'))).or(
  #         a[:trackable_id].in(posts.pluck(:id)).and(a[:trackable_type].eq('Post'))))
  #     .order(:trackable_id, :trackable_type, created_at: :desc)
  #     .sort_by(&:created_at).reverse
  # end

  def activity
    PublicActivity::Activity
      .includes(:owner, :trackable, post: [:user, :images, :graetzl], meeting: [:address, :graetzl])
      .select('DISTINCT ON(trackable_id, trackable_type) *')
      .where(key: STREAM_ACTIVITY_KEYS)
      .where("(owner_id IN (?))
        OR
        (trackable_id IN (?) AND trackable_type = 'Meeting')
        OR
        (trackable_id IN (?) AND trackable_type = 'Post')", users.pluck(:id), meetings.pluck(:id), posts.pluck(:id))
      .order(:trackable_id, :trackable_type, created_at: :desc)
      .sort_by(&:created_at).reverse
  end
end