class CrowdCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :title

  has_and_belongs_to_many :crowd_campaigns

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  def to_s
    title
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

end
