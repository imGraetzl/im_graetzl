class AddNameToCurator < ActiveRecord::Migration
  def up
    add_column :curators, :name, :string

    # migrate existing data
    Curator.find_each do |c|
      c.update(name: c.description)
    end
  end

  def down
    remove_column :curators, :name, :string    
  end
end
