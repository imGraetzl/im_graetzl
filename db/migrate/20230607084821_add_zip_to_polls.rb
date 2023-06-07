class AddZipToPolls < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :zip, :string
  end
end
