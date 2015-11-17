class Curator < ActiveRecord::Base
  belongs_to :graetzl
  belongs_to :user
end
