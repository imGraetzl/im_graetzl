class Graetzl < ApplicationRecord
  extend FriendlyId

  friendly_id :name
  STREAM_ACTIVITY_KEYS = [
    'meeting.comment', 'meeting.create', 'meeting.go_to',
    'user_post.comment', 'user_post.create',
    'admin_post.comment', 'admin_post.create',
    'location_post.comment', 'location_post.create'
  ]

  has_one :curator, dependent: :destroy
  has_many :users
  has_many :meetings, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :room_offers
  has_many :room_demand_graetzls
  has_many :room_demands, through: :room_demand_graetzls
  has_many :operating_ranges
  has_many :initiatives, through: :operating_ranges, source: :operator, source_type: 'Initiative'
  has_many :admin_posts, through: :operating_ranges, source: :operator, source_type: 'Post'

  def districts
    District.where('ST_INTERSECTS(area, :graetzl)', graetzl: self.area)
  end

  def district
    districts.first
  end

  def activity
    Activity.
      includes(:owner, :trackable).
      where(id:
        Activity.select('DISTINCT ON(trackable_id, trackable_type) id').
        where(key: STREAM_ACTIVITY_KEYS).
        where("(trackable_id IN (?) AND trackable_type = 'Meeting')
                OR
                (trackable_id IN (?) AND trackable_type LIKE '%Post')
                OR
                (trackable_id IN (?) AND trackable_type = 'Post')", meetings.ids, posts.ids, admin_posts.ids).
        order(:trackable_id, :trackable_type, id: :desc)
      ).order(id: :desc)
  end

  def decorate_activity(activity_items)
    zuckerl_items = zuckerl_samples(activity_items.count * 0.2).to_a
    merge_items(activity_items, zuckerl_items)
  end

  def zuckerls
    Zuckerl.live.
      includes(location: [:address, :category]).
      where(location_id:
        Location.select(:id).where(graetzl_id:
          Graetzl.select(:id).where("ST_INTERSECTS(area,
            (SELECT ST_UNION(districts.area)
            FROM districts
            WHERE ST_INTERSECTS(districts.area, ?)))", self.area)))
  end

  def build_meeting
    meetings.build(address: Address.new)
  end

  private

  def zuckerl_samples(limit)
    zuckerls.limit(limit).order("RANDOM()")
  end

  def merge_items(a, b)
    a.zip(
      (b + [nil] * (a.size - b.size)).shuffle
    ).flatten.compact
  end
end
