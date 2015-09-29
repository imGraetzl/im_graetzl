class ChangeDefaultLocationState < ActiveRecord::Migration
  def up
    Location.find_each do |l|
      case l[:state]
      when 0
        l.state = 1
      when 1
        l.state = 0
      when 2
        l.state = 1
      end
      l.save
    end

    change_column_default :locations, :state, 0
  end

  def down
  end
end
