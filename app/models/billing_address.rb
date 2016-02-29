class BillingAddress < ActiveRecord::Base
  belongs_to :location

  validates :location, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_city
    "#{first_name} #{last_name}"
  end

  def full_name=(value)
    split = value.split(' ')
    self.last_name = split.pop || ''
    self.first_name = split.join(' ')
  end

  def full_city=(value)
    split = value.split(' ')
    self.zip = split.shift
    self.city = split.join(' ')
  end
end
