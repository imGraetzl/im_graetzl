class RemoveChargeDescriptionFromCrowdBoosts < ActiveRecord::Migration[6.1]
  def change
    remove_column :crowd_boosts, :charge_description, :text
  end
end
