class EnergyOfferCategory < ApplicationRecord
  belongs_to :energy_offer
  belongs_to :energy_category
end
