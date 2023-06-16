class NeighbourGraetzl < ApplicationRecord
  belongs_to :graetzl, :class_name => :Graetzl
  belongs_to :neighbour_graetzl, :class_name => :Graetzl
end