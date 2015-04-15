class Graetzl < ActiveRecord::Base
  # associations
  has_many :users

  # instance methods
  def short_name
    name.split(',')[0]
  end
end
