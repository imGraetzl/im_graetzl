class LocationCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :locations

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  def should_generate_new_friendly_id?
    slug.blank?
  end

end
