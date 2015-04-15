class Graetzl < ActiveRecord::Base
  # associations
  has_many :users

  def short_name
    name.split(',')[0]
  end
end
