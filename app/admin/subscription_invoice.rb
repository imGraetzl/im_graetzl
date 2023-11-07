ActiveAdmin.register SubscriptionInvoice do
  menu parent: 'Subscriptions'
  actions :all, except: [:new, :create, :destroy, :edit]

  scope :all, default: true
  scope :paid
  scope :open
  scope :free
  scope :refunded

  index { render 'index', context: self }
end
