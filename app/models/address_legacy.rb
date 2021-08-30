class AddressLegacy < ApplicationRecord
  self.table_name = 'addresses'

  def street
    return nil if street_name.blank?
    "#{street_name} #{street_number}"
  end

end
