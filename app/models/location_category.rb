class LocationCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :locations

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  scope :visible, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }

  def should_generate_new_friendly_id?
    slug.blank?
  end

  def to_s
    name
  end

end
