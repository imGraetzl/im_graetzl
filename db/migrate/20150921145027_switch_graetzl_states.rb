class SwitchGraetzlStates < ActiveRecord::Migration
  def change
    Graetzl.find_each do |g|
      if g.open?
        g.closed!
      else
        g.open!
      end
    end
  end
end
