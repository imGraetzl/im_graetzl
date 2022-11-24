ActiveAdmin.register Subscription do
  menu label: "Abos", priority: 3

  actions :all, except: [:destroy, :edit]

  scope :initialized, default: true
  scope :active
  scope :canceled
  scope :past_due
  scope :coupon
  scope :all

  index { render 'index', context: self }

end
