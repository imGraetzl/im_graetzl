class AddPositionToPollQuestion < ActiveRecord::Migration[6.1]
  def change
    add_column :polls, :closed, :boolean, default: false
    add_column :poll_questions, :position, :integer, default: 0
  end
end
