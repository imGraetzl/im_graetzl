class LocationCategory < ApplicationRecord
  has_many :locations

  include CategoryImageUploader::Attachment(:main_photo)
  validates_presence_of :main_photo

end
