class AddCoverPhotoContentTypeToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :cover_photo_content_type, :string
  end
end
