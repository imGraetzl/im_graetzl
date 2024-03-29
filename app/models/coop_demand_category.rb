class CoopDemandCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :coop_demands
  has_many :coop_suggested_tags

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def to_s
    name
  end

end
