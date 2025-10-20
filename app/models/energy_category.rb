class EnergyCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :label

  has_many :energy_offer_categories
  has_many :energy_demand_categories
  has_many :energy_offers, through: :energy_offer_categories
  #has_many :energy_demands, through: :energy_demand_categories

  include CategoryImageUploader::Attachment(:main_photo)

  enum :group, { member_type: "member_type", space_type: "space_type", exchange_type: "exchange_type", expert_type: "expert_type", expert_sub_type: "expert_sub_type" }
  scope :main_categories, -> { where.not(group: "expert_sub_type") }

  def to_s
    title
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

end
