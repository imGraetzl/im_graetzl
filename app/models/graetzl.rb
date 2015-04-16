class Graetzl < ActiveRecord::Base
  # associations
  has_many :users
  has_and_belongs_to_many :meetings

  # instance methods
  def short_name
    name.split(',')[0]
  end
end
