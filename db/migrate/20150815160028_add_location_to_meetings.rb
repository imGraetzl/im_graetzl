class AddLocationToMeetings < ActiveRecord::Migration
  def change    
    change_table :meetings do |t|
      t.belongs_to :location, index: true
    end
  end
end
