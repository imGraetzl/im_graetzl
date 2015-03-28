class Address < ActiveRecord::Base

  ## ASSOCIATIONS
  belongs_to :user

  def match_graetzl
    graetzls = Graetzl.where('ST_CONTAINS(area, :point)', point: coordinates)
    graetzls
  end

end
