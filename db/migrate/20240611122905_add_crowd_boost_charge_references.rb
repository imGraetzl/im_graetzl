class AddCrowdBoostChargeReferences < ActiveRecord::Migration[6.1]
  change_table :crowd_boost_charges do |t|
    t.references :zuckerl, foreign_key: { on_delete: :nullify }, index: true
  end
end