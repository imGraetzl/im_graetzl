class CreateNeighbourGraetzls < ActiveRecord::Migration[6.1]
  def change

    create_table "neighbour_graetzls", :force => true do |t|
      t.integer "graetzl_id", :null => false
      t.integer "neighbour_graetzl_id", :null => false
    end

  end
end
