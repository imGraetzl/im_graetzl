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
  has_one :curator, dependent: :destroy
  has_many :users
  has_many :meetings, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :operating_ranges
  has_many :initiatives, through: :operating_ranges

  # instance methods
  def districts
    District.where('ST_INTERSECTS(area, :graetzl)', graetzl: self.area)
  end

  def district
    districts.first
  end

  def feed_items(page)
    items = activity.page(page).per(12)
    if page < 2
      zuckerls = zuckerl_samples(items.size * 0.2).to_a
      items = merge_items(items, zuckerls)
    end
    items
  end

  private

  def zuckerl_samples(limit)
    # TODO: extend on districts level
    Zuckerl.live.where(location: self.locations).limit(limit).order("RANDOM()")
  end

  def activity
    PublicActivity::Activity
      .includes(:owner, :trackable, post: [:author, :images, :graetzl, :comments], meeting: [:address, :graetzl, :comments])
      .where(id:
        PublicActivity::Activity.select('DISTINCT ON(trackable_id, trackable_type) id')
        .where(graetzl_id: self.id, key: STREAM_ACTIVITY_KEYS)
        .order(:trackable_id, :trackable_type, id: :desc)
      ).order(id: :desc)
  end

  def merge_items(a, b)
    a.zip(
      (b + [nil] * (a.size - b.size)).shuffle
    ).flatten.compact
  end
end
