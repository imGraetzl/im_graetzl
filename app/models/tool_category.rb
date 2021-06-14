class ToolCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :parent_category, class_name: "ToolCategory", optional: true
  has_many :tool_offers

  attachment :main_photo, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:main_photo) if main_photo_id_changed? }

  scope :top, -> { where(parent_category_id: nil) }
  scope :subcategories, -> { where("parent_category_id IS NOT NULL") }

  def to_s
    name
  end

  def should_generate_new_friendly_id? #will change the slug if the name changed
    name_changed?
  end

end
