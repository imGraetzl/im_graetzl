class AddGraetzlToMeeting < ActiveRecord::Migration
  def change
    change_table :meetings do |t|
      t.belongs_to :graetzl, index: true
    end
  end
end
