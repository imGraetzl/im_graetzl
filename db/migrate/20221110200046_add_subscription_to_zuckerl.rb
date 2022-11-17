class AddSubscriptionToZuckerl < ActiveRecord::Migration[6.1]
  def change
    add_reference :zuckerls, :subscription, index: true
  end
end
