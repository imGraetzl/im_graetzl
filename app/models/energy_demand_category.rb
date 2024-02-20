class EnergyDemandCategory < ApplicationRecord
  belongs_to :energy_demand
  belongs_to :energy_category
end
