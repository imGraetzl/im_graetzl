class ZuckerlGraetzl < ApplicationRecord
  belongs_to :zuckerl
  belongs_to :graetzl

  # Validierung, um doppelte Einträge zu vermeiden
  validates :zuckerl_id, uniqueness: { scope: :graetzl_id }
end