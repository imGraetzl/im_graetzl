class CreateGraetzlMeetings < ActiveRecord::Migration
  def change
    create_table :graetzl_meetings do |t|
      t.belongs_to :graetzl, index: true
      t.belongs_to :meeting, index: true

      t.timestamps
    end
  end
end
