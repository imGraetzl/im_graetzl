class Address < ApplicationRecord

  def street
    return nil if street_name.blank?
    "#{street_name} #{street_number}"
  end

end
