class EventCategory < ApplicationRecord
  has_and_belongs_to_many :meetings

  include ImageUploader::Attachment(:main_photo)

  def to_s
    title
  end

end
