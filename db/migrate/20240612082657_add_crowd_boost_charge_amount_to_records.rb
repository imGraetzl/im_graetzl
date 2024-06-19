class AddCrowdBoostChargeAmountToRecords < ActiveRecord::Migration[6.1]
  def change

    change_table :crowd_boost_charges do |t|
      t.string "charge_type", default: "general"
      t.references :room_booster, foreign_key: { on_delete: :nullify }, index: true
    end

    add_column :zuckerls, :crowd_boost_charge_amount, :decimal, precision: 10, scale: 2
    add_reference :zuckerls, :crowd_boost, index: true

    add_column :room_boosters, :crowd_boost_charge_amount, :decimal, precision: 10, scale: 2
    add_reference :room_boosters, :crowd_boost, index: true

  end
end
