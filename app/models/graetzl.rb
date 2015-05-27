class Graetzl < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name

  # associations
  has_many :users
  has_many :graetzl_meetings
  has_many :meetings, through: :graetzl_meetings

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
end