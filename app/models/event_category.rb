class EventCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :title

  has_and_belongs_to_many :meetings

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  scope :visible, -> { where(hidden: false) }
  scope :hidden, -> { where(hidden: true) }

  def to_s
    title
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

end
