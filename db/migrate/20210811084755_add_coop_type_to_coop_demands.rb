class AddCoopTypeToCoopDemands < ActiveRecord::Migration[6.1]
  def change
    add_column :coop_demands, :coop_type, :integer, default: 0
  end
end
