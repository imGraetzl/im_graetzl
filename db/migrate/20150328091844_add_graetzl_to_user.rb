class AddGraetzlToUser < ActiveRecord::Migration
  def change
    add_reference :users, :graetzl, index: true
  end
end
