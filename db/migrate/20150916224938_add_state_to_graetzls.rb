class AddStateToGraetzls < ActiveRecord::Migration
  def change
    add_column :graetzls, :state, :integer, default: 0

    District.find_by_zip('1020').graetzls.each do |g|
      g.open!
    end
  end
end
