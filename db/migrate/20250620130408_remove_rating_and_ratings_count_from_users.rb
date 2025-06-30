class RemoveRatingAndRatingsCountFromUsers < ActiveRecord::Migration[6.1]
  def change
    if column_exists?(:users, :rating)
      remove_column :users, :rating
    end

    if column_exists?(:users, :ratings_count)
      remove_column :users, :ratings_count
    end
  end
end
