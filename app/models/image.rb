class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  attachment :file, type: :image
  include RefileShrineSynchronization
  before_save { write_shrine_data(:file) if file_id_changed? }

end
