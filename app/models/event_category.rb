class EventCategory < ApplicationRecord
  has_and_belongs_to_many :meetings

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

  def to_s
    title
  end

end
