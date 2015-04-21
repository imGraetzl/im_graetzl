class ChangeAddressAssociationToPolymorphic < ActiveRecord::Migration
  def change
    change_table :addresses do |t|
      t.remove :user_id
      t.references :addressable, polymorphic: true, index: true
    end
  end
end