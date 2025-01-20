ActiveAdmin.register CouponHistory do
  menu parent: 'Einstellungen'

  index { render 'index', context: self }

  scope :redeemed, default: true
  scope :all

end
