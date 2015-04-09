class ChangeColumnTypeInUser < ActiveRecord::Migration
  def self.up
    change_column :users, :gender, 'integer USING CAST(gender AS integer)'
  end
 
  def self.down
    change_column :users, :gender, 'string USING CAST(gender AS string)'
  end
end
