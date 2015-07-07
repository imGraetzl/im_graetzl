class Graetzl < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name

  # associations
  has_many :users
  has_many :meetings, dependent: :destroy
  has_many :posts, dependent: :destroy

  # attributes
  STREAM_ACTIVITY_KEYS = [
    'meeting.comment', 'meeting.create', 'meeting.go_to',
    'post.comment', 'post.create'
  ]

  # instance methods
  def districts
    District.where('ST_INTERSECTS(area, :graetzl)', graetzl: self.area)
  end

  def activity
    a = PublicActivity::Activity.arel_table
    PublicActivity::Activity
      .select('DISTINCT ON(trackable_id, trackable_type) *')
      .where(a[:key].in(STREAM_ACTIVITY_KEYS))
      .where(
        a[:owner_id].in(users.pluck(:id)).or(
          a[:trackable_id].in(meetings.pluck(:id)).and(a[:trackable_type].eq('Meeting'))).or(
          a[:trackable_id].in(posts.pluck(:id)).and(a[:trackable_type].eq('Post'))))
      .order(:trackable_id, :trackable_type, created_at: :desc)
      .sort_by(&:created_at).reverse
  end
end