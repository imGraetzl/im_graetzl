context.instance_eval do
  column :room_offer
  column(:status) {|price| price&.room_offer&.status }
  column :price_per_hour
  column :minimum_rental_hours
  column :eight_hour_discount
end
