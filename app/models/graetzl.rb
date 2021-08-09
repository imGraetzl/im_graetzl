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
  has_many :room_calls
  has_many :tool_offers
  has_many :group_graetzls
  has_many :groups, through: :group_graetzls

  has_many :district_graetzls
  has_many :districts, through: :district_graetzls

  def self.all_memoized
    @@memoized ||= includes(:districts).map{|g| [g.id, g] }.to_h.freeze
  end

  def self.memoized(id)
    all_memoized[id]
  end

  def zip_name
    "#{zip} – #{name}"
  end

  def numeric
    zip.slice(1..2).sub(%r{^0},"") if zip.present?
  end

  def district
    self.class.memoized(id).districts.first
  end

end
