class Graetzl < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name

  # associations
  has_many :users
  has_and_belongs_to_many :meetings

  # instance methods
  def short_name
    name.split(',')[0]
  end

  def next_meetings
    meetings
      .where.not(starts_at: nil)
      .order(starts_at: :asc)
      .limit(2)
  end
end