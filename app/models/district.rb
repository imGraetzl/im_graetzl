class District < ApplicationRecord
  extend FriendlyId
  friendly_id :long_name

  has_many :district_graetzls
  has_many :graetzls, through: :district_graetzls

  has_many :locations, through: :graetzls
  has_many :meetings, through: :graetzls
  has_many :room_offers, through: :graetzls
  has_many :room_calls, through: :graetzls
  has_many :tool_offers, through: :graetzls
  has_many :location_posts, through: :graetzls

  has_many :room_demands, -> { distinct }, through: :graetzls
  has_many :tool_demands, -> { distinct }, through: :graetzls
  has_many :coop_demands, -> { distinct }, through: :graetzls
  has_many :crowd_campaigns, -> { distinct }, through: :graetzls
  has_many :groups, -> { distinct }, through: :graetzls

  def self.all_memoized
    @@memoized ||= includes(:graetzls).to_h{|d| [d.id.to_s, d] }.freeze
  end

  def self.memoized(id)
    all_memoized[id.to_s]
  end

  def graetzl_ids
    graetzls.map(&:id)
  end

  def long_name
    "#{name}-#{zip}"
  end

  def zip_name
    "#{zip} – #{name}"
  end

  def numeric
    zip.slice(1..2).sub(%r{^0},"") if zip.present?
  end

end
