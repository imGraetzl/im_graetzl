ActiveAdmin.register CouponHistory do
  menu parent: 'Einstellungen'

  index { render 'index', context: self }

  scope :valid, default: true
  scope :redeemed
  scope :expired
  scope :all

end
