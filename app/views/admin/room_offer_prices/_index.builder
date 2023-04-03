context.instance_eval do
  column :room_offer
  column(:status) {|price| price&.room_offer&.status }
  column :amount
  column :name
end
