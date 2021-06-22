class ToolCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :parent_category, class_name: "ToolCategory", optional: true
  has_many :tool_offers

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  scope :top, -> { where(parent_category_id: nil) }
  scope :subcategories, -> { where("parent_category_id IS NOT NULL") }

  def to_s
    name
  end

  def should_generate_new_friendly_id?
    slug.blank?
  end

end
