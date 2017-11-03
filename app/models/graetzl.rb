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

  has_many :district_graetzls
  has_many :districts, through: :district_graetzls

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
    related_graetzl_ids = districts.map(&:graetzl_ids).flatten
    Zuckerl.live.includes(location: [:address, :category]).
      joins(:graetzl).where(graetzls: { id: related_graetzl_ids})
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
