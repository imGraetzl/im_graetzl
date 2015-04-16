class CreateGraetzlsMeetings < ActiveRecord::Migration
  def change
    create_table :graetzls_meetings, id: false do |t|
      t.belongs_to :graetzl, index: true
      t.belongs_to :meeting, index: true
    end
  end
end
