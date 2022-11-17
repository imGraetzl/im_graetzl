class BillingAddress < ApplicationRecord
  belongs_to :location, optional: true
  belongs_to :user, optional: true

  #validates :first_name, presence: true
  #validates :last_name, presence: true

  after_save :update_stripe_customer, if: -> { self.user && self.user.stripe_customer_id? }

  def full_name
    "#{first_name} #{last_name}" if first_name.present? || last_name.present?
  end

  def full_city
    "#{zip} #{city}"
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

  private

  def update_stripe_customer
    Stripe::Customer.update(self.user.stripe_customer_id, {
      name: self.full_name,
      address: {
        line1: self.company,
        line2: self.street,
        postal_code: self.zip,
        city: self.city,
        country: self.country,
      }
    })
  end

end
