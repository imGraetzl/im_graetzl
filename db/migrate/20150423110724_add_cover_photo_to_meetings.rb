class AddCoverPhotoToMeetings < ActiveRecord::Migration
  def change
    add_column :meetings, :cover_photo, :string
  end
end
