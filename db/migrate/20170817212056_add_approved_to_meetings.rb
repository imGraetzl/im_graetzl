class AddApprovedToMeetings < ActiveRecord::Migration[5.0]
  def change
    add_column :meetings, :approved_for_api, :boolean, default: false
  end
end
