class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true

  include GalleryImageUploader::Attachment(:file)
end
