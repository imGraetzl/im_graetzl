class CreateCategoriesMeetingsJoin < ActiveRecord::Migration
  def change
    create_table :categories_meetings, id: false do |t|
      t.belongs_to :category, index: true
      t.belongs_to :meeting, index: true
    end
  end
end