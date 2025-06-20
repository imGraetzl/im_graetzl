class RemoveOwnerAndRenterRatingFromRoomRentals < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:room_rentals, :owner_rating)
      remove_column :room_rentals, :owner_rating
    end

    if column_exists?(:room_rentals, :renter_rating)
      remove_column :room_rentals, :renter_rating
    end
  end
end
