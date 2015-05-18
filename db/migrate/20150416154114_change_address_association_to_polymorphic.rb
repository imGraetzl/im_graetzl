class ChangeAddressAssociationToPolymorphic < ActiveRecord::Migration
  def change
    change_table :addresses do |t|
      t.remove :user_id
      t.date :starts_at_date
      t.date :ends_at_date
      t.time :starts_at_time
      t.time :ends_at_time
    end
  end
end