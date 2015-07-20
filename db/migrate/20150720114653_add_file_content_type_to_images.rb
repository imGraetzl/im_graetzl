class AddFileContentTypeToImages < ActiveRecord::Migration
  def change
    add_column :images, :file_content_type, :string
  end
end
