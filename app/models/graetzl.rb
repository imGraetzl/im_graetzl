class Graetzl < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name

  # associations
  has_many :users
  has_many :meetings, dependent: :destroy
  has_many :posts, dependent: :destroy

  # instance methods
  def short_name
    name.split(',')[0]
  end

  def next_meetings
    meetings
      .where('starts_at_date > ?', Date.yesterday)
      .order(starts_at_date: :asc)
      .limit(2)
  end

  def districts
    District.where('ST_INTERSECTS(area, :graetzl)', graetzl: self.area)
  end

  def activity
    a = PublicActivity::Activity.arel_table
    PublicActivity::Activity.where(
      a[:owner_id].in(users.pluck(:id)).or(
        a[:trackable_id].in(meetings.pluck(:id)).and(a[:trackable_type].eq('Meeting'))).or(
        a[:trackable_id].in(posts.pluck(:id)).and(a[:trackable_type].eq('Post'))))
      .order(created_at: :desc)
  end
end