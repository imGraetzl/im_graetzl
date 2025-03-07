class Graetzl < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :users
  has_many :meetings, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :location_posts
  has_many :locations, dependent: :destroy
  has_many :room_offers
  has_many :room_demand_graetzls
  has_many :room_demands, through: :room_demand_graetzls
  has_many :coop_demand_graetzls
  has_many :coop_demands, through: :coop_demand_graetzls
  has_many :crowd_campaigns
  has_many :tool_offers
  has_many :tool_demand_graetzls
  has_many :tool_demands, through: :tool_demand_graetzls
  has_many :group_graetzls
  has_many :groups, through: :group_graetzls
  has_many :poll_graetzls
  has_many :polls, through: :poll_graetzls
  has_many :energy_offer_graetzls
  has_many :energy_offers, through: :energy_offer_graetzls
  has_many :energy_demand_graetzls
  has_many :energy_demands, through: :energy_demand_graetzls
  has_many :crowd_boost_slot_graetzls
  has_many :crowd_boost_slots, through: :crowd_boost_slot_graetzls
  has_many :zuckerl_graetzls
  has_many :zuckerls, through: :zuckerl_graetzls

  has_many :district_graetzls
  has_many :districts, through: :district_graetzls

  has_many :neighbour_graetzls, :foreign_key => :graetzl_id, :dependent => :destroy
  has_many :reverse_neighbour_graetzls, :class_name => :NeighbourGraetzl, :foreign_key => :neighbour_graetzl_id, :dependent => :destroy
  has_many :neighbours, :through => :neighbour_graetzls, :source => :neighbour_graetzl

  def self.all_memoized
    @@memoized ||= includes(:districts).to_h{|g| [g.id.to_s, g] }.freeze
  end

  def self.memoized(id)
    all_memoized[id.to_s]
  end

  def self.find_by_coords(region, coordinates)
    return if coordinates.blank?
    point = RGeo::Cartesian.factory(srid: 0).point(*coordinates)
    region.graetzls.find{|g| g.area.contains?(point)}
  end

  def to_s
    name
  end

  def zip_name
    zip.present? ? "#{zip} – #{name}" : name
  end

  def numeric
    zip.slice(1..2).sub(%r{^0},"") if zip.present?
  end

  def district
    self.class.memoized(id).districts.first
  end

  def district_id
    district&.id
  end

  def default_neighbour_graetzls

    if neighbours.present?
      neighbours - [self]
    elsif neighborless?
      []
    elsif region.use_districts?
      district.graetzls - [self]
    elsif region.graetzls.any?(&:neighborless?)
      Graetzl.in(region).where(neighborless: false) - [self]
    else
      region.graetzls - [self]
    end
    
  end

end
